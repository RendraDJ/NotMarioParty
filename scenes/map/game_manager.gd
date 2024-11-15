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

# Load the coin scene
var CoinScene = preload("res://scenes/map/coin.tscn")  # Replace with the actual path to your Coin scene

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
		await get_tree().create_timer(move_delay).timeout  # Use await here to wait for the timer
		player.position = tile_coordinates[i]
	
	# Check tile effect only after reaching the target position
	check_tile_effect(player)
	return target_pos

# Function to check if player landed on a special tile and apply effects
func check_tile_effect(player: Node2D):
	var player_position = player.position
	for position in bonus_tiles:
		if player_position.distance_to(position) < 10:  # Allowing small tolerance
			print(player.name, " landed on a bonus tile!")
			gain_coins(player, 5)
			return  # Return after applying bonus

	for position in minus_tiles:
		if player_position.distance_to(position) < 10:  # Allowing small tolerance
			print(player.name, " landed on a minus tile!")
			gain_coins(player, -3)
			return  # Return after applying minus

	if player_position == star_tile:
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

# Function to add a star to the player
func gain_star(player: Node2D):
	if player == player1:
		player1_stars += 1
		print("Player 1 stars:", player1_stars)  # Debugging line
		update_player_ui(player1)
	elif player == player2:
		player2_stars += 1
		print("Player 2 stars:", player2_stars)  # Debugging line
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
	print("New star tile position:", star_tile)  # Debugging line

# Function to place coins on the bonus tiles
func place_coins():
	for position in bonus_tiles:
		print("Placing coin at: ", position)  # Debugging line
		var coin_instance = CoinScene.instantiate()
		coin_instance.position = position
		coin_instance.z_index = 10  # Make sure the coins appear above other tiles
		add_child(coin_instance)

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
	place_coins()  # Place coins on bonus tiles
	play_game()

# Main function to control the game flow
func play_game():
	while true:  # Loop until the game ends
		# Player 1 rolls the dice and moves
		var player1_roll = roll_dice()
		print("Player 1 rolls: ", player1_roll)
		player1_position = await move_player(player1, player1_position, player1_roll)
		
		# Player 2's turn
		await get_tree().create_timer(1.0).timeout
		var player2_roll = roll_dice()
		print("Player 2 rolls: ", player2_roll)
		player2_position = await move_player(player2, player2_position, player2_roll)
		
		# Delay before looping again
		await get_tree().create_timer(1.0).timeout
