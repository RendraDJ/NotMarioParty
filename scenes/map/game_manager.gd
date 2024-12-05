extends Node2D

@export var player_one_score: Label
@export var player_two_score: Label
@export var game_logs: RichTextLabel

@export var PlayerScene: PackedScene
@export var CoinScene: PackedScene
@export var StarScene: PackedScene
@export var MysteryBoxScene: PackedScene

var tile_coordinates = [
	Vector2(377, 587), Vector2(368, 517), Vector2(368, 452), Vector2(368, 388), Vector2(432, 388),
	Vector2(495, 388), Vector2(558, 388), Vector2(623, 388), Vector2(689, 388), Vector2(752, 388),
	Vector2(784, 321), Vector2(784, 259), Vector2(784, 196), Vector2(784, 132), Vector2(784, 67),
	Vector2(784, 4), Vector2(720, 4), Vector2(655, 4), Vector2(592, 4), Vector2(529, 4),
	Vector2(463, 4), Vector2(399, 4), Vector2(336, 68), Vector2(271, 133), Vector2(208, 196),
	Vector2(144, 196), Vector2(111, 259), Vector2(48, 259), Vector2(48, 324), Vector2(48, 388),
	Vector2(48, 452), Vector2(110, 452), Vector2(175, 452), Vector2(239, 452), Vector2(306, 452),
	Vector2(368, 452)
]

var bonus_tiles = []
var minus_tiles = []
var mystery_box_tiles = []

var coins_on_tiles = {}
var mystery_boxes_on_tiles = {}
var stars_on_tiles = {}  # Dictionary to track stars and their positions

var move_delay = 0.3
var dice_min = 1
var dice_max = 6

var player1: Player
var player2: Player

var random = RandomNumberGenerator.new()

func _ready():
	var player1_texture = preload("res://assets/characters/2d/mario.png")
	var player2_texture = preload("res://assets/characters/2d/luigi.png")
	
	player1 = PlayerScene.instantiate()
	player1.player_name = "Player 1"
	player1.score_label = player_one_score
	player1.game_manager = self
	player1.sprite_texture = player1_texture  # Assign texture for Player 1
	add_child(player1)

	player2 = PlayerScene.instantiate()
	player2.player_name = "Player 2"
	player2.score_label = player_two_score
	player2.game_manager = self
	player2.sprite_texture = player2_texture  # Assign texture for Player 2
	add_child(player2)

	generate_random_tiles()
	place_special_tiles()
	player1._update_ui()
	player2._update_ui()

	play_game()

func log_message(message: String, player: Player = null):
	if game_logs:
		if player == player1:
			game_logs.append_bbcode("[color=#0000FF]" + message + "[/color]\n")  # Bleu
		elif player == player2:
			game_logs.append_bbcode("[color=#FF66B2]" + message + "[/color]\n")  # Rose
		else:
			game_logs.add_text(message + "\n")  # Couleur par défaut
		game_logs.scroll_to_line(game_logs.get_line_count() - 1)

func roll_dice() -> int:
	var roll = random.randi_range(dice_min, dice_max)
	log_message("Dice rolled: " + str(roll))
	return roll

func move_player(player: Player, steps: int) -> void:
	await player.move(tile_coordinates, steps, move_delay)
	check_tile_interaction(player)

func play_game():
	while true:
		var player1_roll = roll_dice()
		await move_player(player1, player1_roll)
		await get_tree().create_timer(1.0).timeout

		var player2_roll = roll_dice()
		await move_player(player2, player2_roll)
		await get_tree().create_timer(1.0).timeout

		# End game if both players are on the last tile
		if player1.tile_index == tile_coordinates.size() - 1 and player2.tile_index == tile_coordinates.size() - 1:
			determine_winner()
			break

func determine_winner():
	# Convert coins into stars (1 star = 25 coins)
	var player1_stars_from_coins = player1.coins / 25
	var player2_stars_from_coins = player2.coins / 25

	# Add the stars each player already has to the converted stars from coins
	var player1_total_stars = player1.stars + player1_stars_from_coins
	var player2_total_stars = player2.stars + player2_stars_from_coins

	# Compare the total stars (stars + stars from coins)
	if player1_total_stars > player2_total_stars:
		log_message("Player 1 wins with more stars!")
	elif player2_total_stars > player1_total_stars:
		log_message("Player 2 wins with more stars!")
	else:
		# If stars are equal, compare the remaining coins
		var player1_remaining_coins = player1.coins % 25
		var player2_remaining_coins = player2.coins % 25

		if player1_remaining_coins > player2_remaining_coins:
			log_message("It's a tie in stars, but Player 1 wins with more remaining coins!")
		elif player2_remaining_coins > player1_remaining_coins:
			log_message("It's a tie in stars, but Player 2 wins with more remaining coins!")
		else:
			log_message("It's a tie in both stars and remaining coins!")


func generate_random_tiles():
	var available_tiles = tile_coordinates.duplicate()
	random.randomize()
	available_tiles.shuffle()
	bonus_tiles = available_tiles.slice(0, 6)
	minus_tiles = available_tiles.slice(6, 12)
	mystery_box_tiles = available_tiles.slice(12, 15)

func place_special_tiles():
	place_coins()
	place_stars()
	place_mystery_boxes()

func place_coins():
	for coin_tile in bonus_tiles:
		var coin_instance = CoinScene.instantiate()
		coin_instance.position = coin_tile
		add_child(coin_instance)
		coins_on_tiles[coin_tile] = coin_instance

	for minus_tile in minus_tiles:
		var minus_instance = CoinScene.instantiate()
		minus_instance.position = minus_tile
		minus_instance.modulate = Color(1, 0, 0)
		add_child(minus_instance)
		coins_on_tiles[minus_tile] = minus_instance

func place_stars():
	var available_tiles = []
	
	# Filtrer uniquement les cases vides (sans coins, mystery boxes ou stars)
	for tile in tile_coordinates:
		if not (tile in coins_on_tiles or tile in mystery_boxes_on_tiles or tile in stars_on_tiles):
			available_tiles.append(tile)
	
	random.randomize()
	available_tiles.shuffle()

	# Générer jusqu'à 3 étoiles sur des cases vides
	for i in range(3):
		if available_tiles.size() == 0:
			break
		var star_tile = available_tiles.pop_back()
		var star_instance = StarScene.instantiate()
		star_instance.position = star_tile
		add_child(star_instance)
		stars_on_tiles[star_tile] = star_instance



	# Generate 3 random positions for the stars
	for i in range(3):
		if available_tiles.size() == 0:
			break
		var star_tile = available_tiles.pop_back()
		var star_instance = StarScene.instantiate()
		star_instance.position = star_tile
		add_child(star_instance)
		stars_on_tiles[star_tile] = star_instance

func place_mystery_boxes():
	var available_tiles = []
	
	# Filtrer uniquement les cases vides (sans coins, stars ou mystery boxes)
	for tile in tile_coordinates:
		if not (tile in coins_on_tiles or tile in mystery_boxes_on_tiles or tile in stars_on_tiles):
			available_tiles.append(tile)
	
	random.randomize()
	available_tiles.shuffle()

	# Générer les mystery boxes
	for mystery_box_tile in mystery_box_tiles:
		if available_tiles.size() == 0:
			break
		var box_instance = MysteryBoxScene.instantiate()
		box_instance.position = available_tiles.pop_back()
		add_child(box_instance)
		mystery_boxes_on_tiles[box_instance.position] = box_instance


func check_tile_interaction(player: Player):
	var current_tile = tile_coordinates[player.tile_index]

	# Gestion des bonus coins
	if current_tile in bonus_tiles and current_tile in coins_on_tiles:
		log_message(player.player_name + " landed on a bonus tile!")
		player.gain_coins(10)
		if is_instance_valid(coins_on_tiles[current_tile]):
			_reposition_object(coins_on_tiles[current_tile], bonus_tiles)
		coins_on_tiles.erase(current_tile)

	# Gestion des minus coins
	elif current_tile in minus_tiles and current_tile in coins_on_tiles:
		log_message(player.player_name + " landed on a minus tile!")
		player.gain_coins(-5)
		if is_instance_valid(coins_on_tiles[current_tile]):
			_reposition_object(coins_on_tiles[current_tile], minus_tiles)
		coins_on_tiles.erase(current_tile)

	# Gestion des mystery boxes
	elif current_tile in mystery_boxes_on_tiles:
		log_message(player.player_name + " found a mystery box!")
		var box_instance = mystery_boxes_on_tiles[current_tile]
		if is_instance_valid(box_instance):
			_reposition_object(box_instance, mystery_box_tiles)
		resolve_mystery_box(player, current_tile)
		# Remove the box after interaction, but only once
		if is_instance_valid(box_instance):
			box_instance.queue_free()
			mystery_boxes_on_tiles.erase(current_tile)

	# Gestion des étoiles
	elif current_tile in stars_on_tiles:
		log_message(player.player_name + " collected a star!")
		player.gain_star()
		if is_instance_valid(stars_on_tiles[current_tile]):
			stars_on_tiles[current_tile].queue_free()
		stars_on_tiles.erase(current_tile)


	# Gestion des étoiles
	elif current_tile in stars_on_tiles:
		log_message(player.player_name + " collected a star!")
		player.gain_star()
		if is_instance_valid(stars_on_tiles[current_tile]):
			stars_on_tiles[current_tile].queue_free()
		stars_on_tiles.erase(current_tile)


func _reposition_object(object: Node2D, tile_list: Array):
	if not is_instance_valid(object):
		log_message("Cannot reposition object: it has already been freed.")
		return

	var available_tiles = []
	for tile in tile_coordinates:
		if not (tile in coins_on_tiles or tile in mystery_boxes_on_tiles or tile in stars_on_tiles):
			available_tiles.append(tile)

	if available_tiles.size() > 0:
		var new_tile = available_tiles[random.randi_range(0, available_tiles.size() - 1)]
		object.position = new_tile

		if object in coins_on_tiles.values():
			tile_list.append(new_tile)
			coins_on_tiles[new_tile] = object
		elif object in mystery_boxes_on_tiles.values():
			tile_list.append(new_tile)
			mystery_boxes_on_tiles[new_tile] = object
		elif object in stars_on_tiles.values():
			stars_on_tiles[new_tile] = object
	else:
		log_message("No available tiles to reposition the object.")

func resolve_mystery_box(player: Player, tile: Vector2):
	var effect = random.randi_range(1, 3)
	if effect == 1:
		player.gain_coins(20)
		log_message(player.player_name + " gained 20 coins from the mystery box!")
	elif effect == 2:
		player.gain_coins(-10)
		log_message(player.player_name + " lost 10 coins from the mystery box!")
	elif effect == 3:
		player.gain_star()
		log_message(player.player_name + " found a star in the mystery box!")
	# The mystery box is already freed in check_tile_interaction, no need to free it here
	if tile in mystery_boxes_on_tiles:
		mystery_boxes_on_tiles.erase(tile)
