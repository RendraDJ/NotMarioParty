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
var bonus_tiles = [
	Vector2(368, 452), 
	Vector2(623, 388),
	Vector2(480, 300),  # New bonus tile
	Vector2(300, 450),  # New bonus tile
	Vector2(540, 200),  # New bonus tile
	Vector2(720, 200),  # New bonus tile
	Vector2(150, 100),  # New bonus tile
	Vector2(375, 450),  # New bonus tile
	Vector2(650, 350)   # New bonus tile
] 

var minus_tiles = [
	Vector2(144, 196), 
	Vector2(48, 324),
	Vector2(400, 100),  # New minus tile
	Vector2(500, 350),  # New minus tile
	Vector2(150, 250),  # New minus tile
	Vector2(300, 100),  # New minus tile
	Vector2(450, 450),  # New minus tile
	Vector2(600, 250)   # New minus tile
]   

var star_tile = Vector2(784, 132)  # Starting position of the star tile

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

# Function to roll dice
func roll_dice() -> int:
	return random.randi_range(dice_min, dice_max)

# Function to move the player along the path
func move_player(player: Node2D, start_pos: int, steps: int) -> int:
	var target_pos = min(start_pos + steps, tile_coordinates.size())
	for i in range(start_pos, target_pos):
		await get_tree().create_timer(move_delay).timeout
		player.position = tile_coordinates[i]
	
	# Check tile effect only after reaching the target position
	check_tile_effect(player)
	return target_pos

# Function to check if player landed on a special tile and apply effects
func check_tile_effect(player: Node2D):
	var player_position = player.position
	if player_position in bonus_tiles:
		print(player.name, " landed on a bonus tile!")
		gain_coins(player, 5)  # Gain 5 coins
	elif player_position in minus_tiles:
		print(player.name, " landed on a minus tile!")
		gain_coins(player, -3)  # Lose 3 coins
	elif player_position == star_tile:
		print(player.name, " collected a star!")
		gain_star(player)
		move_star_tile()  # Move the star to a new position

# Function to add or subtract coins
func gain_coins(player: Node2D, amount: int):
	if player == player1:
		player1_coins += amount
		print("Player 1 coins:", player1_coins)  # Debugging line
		update_player_ui(player1)
	elif player == player2:
		player2_coins += amount
		print("Player 2 coins:", player2_coins)  # Debugging line
		update_player_ui(player2)

# Function to add a star
func gain_star(player: Node2D):
	if player == player1:
		player1_stars += 1
		print("Player 1 stars:", player1_stars)  # Debugging line
		update_player_ui(player1)
	elif player == player2:
		player2_stars += 1
		print("Player 2 stars:", player2_stars)  # Debugging line
		update_player_ui(player2)

# Function to update the UI with the player’s coin and star counts
func update_player_ui(player: Node2D):
	if player == player1:
		if player_one_score:
			player_one_score.text = "Coins: %d, Stars: %d" % [player1_coins, player1_stars]
		else:
			print("Error: player_one_score label is not assigned or doesn't exist.")
	elif player == player2:
		if player_two_score:
			player_two_score.text = "Coins: %d, Stars: %d" % [player2_coins, player2_stars]
		else:
			print("Error: player_two_score label is not assigned or doesn't exist.")

# Function to move the star tile to a random location
func move_star_tile():
	star_tile = tile_coordinates[random.randi_range(0, tile_coordinates.size() - 1)]
	print("Star has moved to:", star_tile)

# Function to play the game automatically
func play_game():
	while player1_position < tile_coordinates.size() and player2_position < tile_coordinates.size():
		
		# Player 1 rolls the dice and moves
		var player1_roll = roll_dice()
		print("Player 1 rolls: ", player1_roll)
		player1_position = await move_player(player1, player1_position, player1_roll)
		await get_tree().create_timer(1.0).timeout # Add a delay between turns
		
		# Player 2 rolls the dice and moves
		var player2_roll = roll_dice()
		print("Player 2 rolls: ", player2_roll)
		player2_position = await move_player(player2, player2_position, player2_roll)
		await get_tree().create_timer(1.0).timeout # Add a delay between turns

# Start the game automatically when the scene is ready
func _ready():
	# Check if score labels are set
	if not player_one_score:
		print("Warning: player_one_score label is not assigned.")
	if not player_two_score:
		print("Warning: player_two_score label is not assigned.")
	
	# Initialize the UI for both players
	update_player_ui(player1)
	update_player_ui(player2)
	
	# Start the game
	play_game()
