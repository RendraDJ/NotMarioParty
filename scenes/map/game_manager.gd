extends Node2D

@export var player1: Node2D
@export var player2: Node2D

@export var player_one_score: Label
@export var player_two_score: Label

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
var star_tile = Vector2(784, 132)

# Load the coin scene
var CoinScene = preload("res://scenes/map/coin.tscn")  # Replace with the actual path to your Coin scene

# Dictionary to map tile positions to their coin instances
var coins_on_tiles = {}

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

# Function to randomly select tiles for bonus and minus tiles
func generate_random_tiles():
	var available_tiles = tile_coordinates.duplicate()  # Copy tile coordinates to avoid modifying the original
	
	# Shuffle the tiles for randomness
	random.randomize()
	available_tiles.shuffle()
	
	# Select the first 6 tiles for bonus
	bonus_tiles = available_tiles.slice(0, 6)
	
	# Select the next 6 tiles for minus
	minus_tiles = available_tiles.slice(6, 12)
	
	print("Generated Bonus Tiles: ", bonus_tiles)
	print("Generated Minus Tiles: ", minus_tiles)

# Function to roll dice
func roll_dice() -> int:
	return random.randi_range(dice_min, dice_max)

# Function to move the player along the path
func move_player(player: Node2D, start_pos: int, steps: int) -> int:
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
			gain_coins(player, 5)
			# Remove the tile from bonus_tiles so it won't affect others
			bonus_tiles.erase(bonus_tile)
			return

	for minus_tile in minus_tiles:
		if player_position.distance_to(minus_tile) < 10:
			print(player.name, " landed on a minus tile!")
			gain_coins(player, -3)
			# Remove the tile from minus_tiles
			minus_tiles.erase(minus_tile)
			return

	if player_position == star_tile:
		print(player.name, " collected a star!")
		gain_star(player)
		move_star_tile()

# Function to add or subtract coins and handle coin collection
func gain_coins(player: Node2D, amount: int):
	var player_position = player.position
	for coin_tile in coins_on_tiles.keys():
		if player_position.distance_to(coin_tile) < 10:
			# Remove the coin instance
			var coin_instance = coins_on_tiles[coin_tile]
			if coin_instance:
				coin_instance.queue_free()
				coins_on_tiles.erase(coin_tile)
				print("Coin collected at: ", coin_tile)

	if player == player1:
		player1_coins += amount
		print("Player 1 coins:", player1_coins)
		update_player_ui(player1)
	elif player == player2:
		player2_coins += amount
		print("Player 2 coins:", player2_coins)
		update_player_ui(player2)

# Function to add a star to the player
func gain_star(player: Node2D):
	if player == player1:
		player1_stars += 1
		print("Player 1 stars:", player1_stars)
		update_player_ui(player1)
	elif player == player2:
		player2_stars += 1
		print("Player 2 stars:", player2_stars)
		update_player_ui(player2)

# Function to update player UI labels
func update_player_ui(player: Node2D):
	if player == player1:
		player_one_score.text = "Player 1: Coins = " + str(player1_coins) + ", Stars = " + str(player1_stars)
	elif player == player2:
		player_two_score.text = "Player 2: Coins = " + str(player2_coins) + ", Stars = " + str(player2_stars)

# Move the star tile to a new random position
func move_star_tile():
	star_tile = tile_coordinates[random.randi_range(0, tile_coordinates.size() - 1)]
	print("New star tile position:", star_tile)

# Function to place coins on bonus and minus tiles
func place_coins():
	# Place bonus coins
	for coin_tile in bonus_tiles:
		print("Placing bonus coin at: ", coin_tile)
		var coin_instance = CoinScene.instantiate()
		coin_instance.position = coin_tile
		coin_instance.z_index = 10
		add_child(coin_instance)
		coins_on_tiles[coin_tile] = coin_instance

	# Place minus coins
	for minus_tile in minus_tiles:
		print("Placing minus coin at: ", minus_tile)
		var minus_instance = CoinScene.instantiate()
		minus_instance.position = minus_tile
		minus_instance.z_index = 10
		minus_instance.modulate = Color(1, 0, 0)  # Change the color to red to differentiate
		add_child(minus_instance)
		coins_on_tiles[minus_tile] = minus_instance

# Start the game automatically when the scene is ready
func _ready():
	# Generate random bonus and minus tiles
	generate_random_tiles()

	if not player_one_score:
		print("Warning: player_one_score label is not assigned.")
	if not player_two_score:
		print("Warning: player_two_score label is not assigned.")
	
	update_player_ui(player1)
	update_player_ui(player2)
	place_coins()
	play_game()

# Main function to control the game flow
func play_game():
	while true:
		var player1_roll = roll_dice()
		print("Player 1 rolls: ", player1_roll)
		player1_position = await move_player(player1, player1_position, player1_roll)
		
		await get_tree().create_timer(1.0).timeout
		var player2_roll = roll_dice()
		print("Player 2 rolls: ", player2_roll)
		player2_position = await move_player(player2, player2_position, player2_roll)
		
		await get_tree().create_timer(1.0).timeout
