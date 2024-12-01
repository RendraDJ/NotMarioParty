extends Node2D

@export var player1: Node2D
@export var player2: Node2D

@export var player_one_score: Label
@export var player_two_score: Label
@export var game_logs: RichTextLabel


# Yellow tile coordinates (coordinates must be added manually in the order of movement)
var tile_coordinates = [
	Vector2(377, 587),
Vector2(368, 517),
Vector2(368, 452),
Vector2(368, 388),
Vector2(432, 388),
Vector2(495, 388),
Vector2(558, 388),
Vector2(623, 388),
Vector2(689, 388),
Vector2(752, 388),
Vector2(784, 321),
Vector2(784, 259),
Vector2(784, 196),
Vector2(784, 132),
Vector2(784, 67),
Vector2(784, 4),
Vector2(720, 4),
Vector2(655, 4),
Vector2(592, 4),
Vector2(529, 4),
Vector2(463, 4),
Vector2(399, 4),
Vector2(336, 68),
Vector2(271, 133),
Vector2(208, 196),
Vector2(144, 196),
Vector2(111, 259),
Vector2(48, 259),
Vector2(48, 324),
Vector2(48, 388),
Vector2(48, 452),
Vector2(110, 452),
Vector2(175, 452),
Vector2(239, 452),
Vector2(306, 452),
Vector2(368, 452)
]

# Define the positions of bonus, minus, and star tiles
var bonus_tiles = []
var minus_tiles = []
var star_tile = Vector2(48, 452)
var mystery_box_tiles = []

# Load scenes
var CoinScene = preload("res://scenes/map/coin.tscn")
var StarScene = preload("res://scenes/map/star.tscn")
var MysteryBoxScene = preload("res://scenes/map/mystery_box.tscn")

# Dictionary to map tile positions to their coin and box instances
var coins_on_tiles = {}
var mystery_boxes_on_tiles = {}

# Player positions in the tile path
var player1_position = 0
var player2_position = 0

# Dice roll range
var dice_min = 1
var dice_max = 6

# Set a delay for movement
var move_delay = 0.3

# Player coin and star counts
var player1_coins = 0
var player2_coins = 0
var player1_stars = 0
var player2_stars = 0

# Random number generator for dice rolls and tile assignment
var random = RandomNumberGenerator.new()

# Star instance
var star_instance: Node2D = null

func log_message(message: String):
	if game_logs:
		game_logs.add_text(message + "\n")
		game_logs.scroll_to_line(game_logs.get_line_count() - 1)  # Scroll to the latest message


# Function to randomly select tiles for bonus, minus, and mystery boxes
func generate_random_tiles():
	var available_tiles = tile_coordinates.duplicate()
	random.randomize()
	available_tiles.shuffle()
	bonus_tiles = available_tiles.slice(0, 6)
	minus_tiles = available_tiles.slice(6, 12)
	mystery_box_tiles = available_tiles.slice(12, 15)

# Function to roll dice
func roll_dice() -> int:
	var roll = random.randi_range(dice_min, dice_max)
	log_message("Dice rolled: " + str(roll))
	return roll

# Function to move the player along the path
func move_player(player: Node2D, start_pos: int, steps: int) -> int:
	log_message(player.name + " moves " + str(steps) + " steps.")
	var target_pos = min(start_pos + steps, tile_coordinates.size())
	for i in range(start_pos, target_pos):
		await get_tree().create_timer(move_delay).timeout
		player.position = tile_coordinates[i]
		check_tile_effect(player)
	return target_pos

# Function to check if player landed on a special tile and apply effects
func check_tile_effect(player: Node2D):
	var player_position = player.position
	for bonus_tile in bonus_tiles:
		if player_position.distance_to(bonus_tile) < 10:
			print(player.name, " landed on a bonus tile!")
			log_message(player.name + " landed on a bonus tile and gained 5 coins!")
			gain_coins(player, 5)
			# Remove the coin instance
			if coins_on_tiles.has(bonus_tile):
				coins_on_tiles[bonus_tile].queue_free()
				coins_on_tiles.erase(bonus_tile)
			bonus_tiles.erase(bonus_tile)
			return
	for minus_tile in minus_tiles:
		if player_position.distance_to(minus_tile) < 10:
			print(player.name, " landed on a minus tile!")
			log_message(player.name + " landed on a minus tile and lost 3 coins!")
			gain_coins(player, -3)
			# Remove the coin instance
			if coins_on_tiles.has(minus_tile):
				coins_on_tiles[minus_tile].queue_free()
				coins_on_tiles.erase(minus_tile)
			minus_tiles.erase(minus_tile)
			return
	if player_position == star_tile:
		print(player.name, " collected a star!")
		log_message(player.name + " landed on a star tile and collected a star!")
		gain_star(player)
		move_star_tile()
		place_star()
		return
	for box_tile in mystery_boxes_on_tiles.keys():
		if player_position.distance_to(box_tile) < 10:
			print(player.name, " collected a mystery box!")
			log_message(player.name + " landed on a myster box tile and collected a box!")
			handle_mystery_box(player, box_tile)
			return

# Function to handle the collection of a mystery box
func handle_mystery_box(player: Node2D, box_tile: Vector2):
	log_message(player.name + " picked up a mystery box!")
	var mystery_box_instance = mystery_boxes_on_tiles[box_tile]
	if mystery_box_instance:
		mystery_box_instance.queue_free()
		mystery_boxes_on_tiles.erase(box_tile)

	var player_coins = player1_coins if player == player1 else player2_coins
	var player_stars = player1_stars if player == player1 else player2_stars
	var opponent_coins = player2_coins if player == player1 else player1_coins
	var opponent_stars = player2_stars if player == player1 else player1_stars
	var player_score = player_coins + (player_stars * 10)
	var opponent_score = opponent_coins + (opponent_stars * 10)

	if player_score > opponent_score:
		print(player.name, " must choose:")
		print("1: Get richer")
		print("2: Give problems to the other player")
		var choice = 1  # Hard-code for now; replace with UI later
		if choice == 1:
			execute_richer_outcome(player)
		elif choice == 2:
			execute_problem_outcome(player, opponent_coins, opponent_stars)
	else:
		print(player.name, " chose to give problems to the other player (automatic)")
		execute_problem_outcome(player, opponent_coins, opponent_stars)

	respawn_mystery_box()

	
func execute_richer_outcome(player: Node2D):
	var outcome = random.randi_range(1, 100)
	if outcome <= 40:  # 40% chance to win 5 coins
		gain_coins(player, 5)
		print(player.name, " won 5 coins!")
	elif outcome <= 80:  # Next 40% chance to lose 10 coins
		gain_coins(player, -10)
		print(player.name, " lost 10 coins!")
	else:  # Remaining 20% chance to win a star
		gain_star(player)
		print(player.name, " won a star!")

func execute_problem_outcome(player: Node2D, opponent_coins: int, opponent_stars: int):
	var outcome = random.randi_range(1, 100)
	if outcome <= 40:  # 40% chance to make the opponent lose 5 coins
		if player == player1:
			player2_coins = max(0, player2_coins - 5)
		else:
			player1_coins = max(0, player1_coins - 5)
		print("The opponent lost 5 coins!")
	elif outcome <= 80:  # Next 40% chance to lose 10 coins themselves
		gain_coins(player, -10)
		print(player.name, " lost 10 coins!")
	else:  # Remaining 20% chance to make the opponent lose a star
		if player == player1:
			player2_stars = max(0, player2_stars - 1)
		else:
			player1_stars = max(0, player1_stars - 1)
		print("The opponent lost a star!")
	update_player_ui(player1)
	update_player_ui(player2)


# Function to respawn a mystery box
func respawn_mystery_box():
	var available_tiles = tile_coordinates.duplicate()
	for occupied_tile in mystery_boxes_on_tiles.keys():
		available_tiles.erase(occupied_tile)
	if available_tiles.size() > 0:
		random.randomize()
		var new_tile = available_tiles[random.randi_range(0, available_tiles.size() - 1)]
		var new_mystery_box_instance = MysteryBoxScene.instantiate()
		new_mystery_box_instance.position = new_tile
		new_mystery_box_instance.z_index = 10
		add_child(new_mystery_box_instance)
		mystery_boxes_on_tiles[new_tile] = new_mystery_box_instance

# Function to gain or lose coins
func gain_coins(player: Node2D, amount: int):
	if player == player1:
		player1_coins += amount
		# Correctly indented with tabs
	elif player == player2:
		player2_coins += amount
		# Correctly indented with tabs

# Function to gain a star
func gain_star(player: Node2D):
	if player == player1:
		player1_stars += 1
		log_message("Player 1 collects a star!")
		update_player_ui(player1)
	elif player == player2:
		player2_stars += 1
		log_message("Player 2 collects a star!")
		update_player_ui(player2)

# Function to update player UI
func update_player_ui(player: Node2D):
	if player == player1:
		player_one_score.text = "Player 1: Coins = " + str(player1_coins) + ", Stars = " + str(player1_stars)
	elif player == player2:
		player_two_score.text = "Player 2: Coins = " + str(player2_coins) + ", Stars = " + str(player2_stars)

# Move star tile to a new position
func move_star_tile():
	star_tile = tile_coordinates[random.randi_range(0, tile_coordinates.size() - 1)]
	if star_instance:
		star_instance.position = star_tile

# Place star
func place_star():
	if not star_instance:
		star_instance = StarScene.instantiate()
		add_child(star_instance)
	star_instance.position = star_tile

# Place mystery boxes
func place_mystery_boxes():
	for mystery_box_tile in mystery_box_tiles:
		var mystery_box_instance = MysteryBoxScene.instantiate()
		mystery_box_instance.position = mystery_box_tile
		mystery_box_instance.z_index = 10
		add_child(mystery_box_instance)
		mystery_boxes_on_tiles[mystery_box_tile] = mystery_box_instance

# Place coins
func place_coins():
	for coin_tile in bonus_tiles:
		var coin_instance = CoinScene.instantiate()
		coin_instance.position = coin_tile
		coin_instance.z_index = 10
		add_child(coin_instance)
		coins_on_tiles[coin_tile] = coin_instance
	for minus_tile in minus_tiles:
		var minus_instance = CoinScene.instantiate()
		minus_instance.position = minus_tile
		minus_instance.z_index = 10
		minus_instance.modulate = Color(1, 0, 0)
		add_child(minus_instance)
		coins_on_tiles[minus_tile] = minus_instance

# Ready function
func _ready():
	generate_random_tiles()
	update_player_ui(player1)
	update_player_ui(player2)
	place_coins()
	place_star()
	place_mystery_boxes()
	play_game()

# Main game loop
func play_game():
	while true:
		var player1_roll = roll_dice()
		player1_position = await move_player(player1, player1_position, player1_roll)
		await get_tree().create_timer(1.0).timeout
		var player2_roll = roll_dice()
		player2_position = await move_player(player2, player2_position, player2_roll)
		await get_tree().create_timer(1.0).timeout
