extends Node2D

# Declare variables for players and their positions on the map
@export var player1: Node2D
@export var player2: Node2D

# Yellow tile coordinates (coordinates must be added manually in the order of movement)
var tile_coordinates = [
	Vector2(377,587),
	Vector2(368,517),
	Vector2(368,452),
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
	Vector2(368,452)
]

# Player positions in the tile path
var player1_position = 0
var player2_position = 0

# Dice roll range
var dice_min = 1
var dice_max = 6

# Set a delay for movement
var move_delay = 0.3

# Random number generator for dice rolls
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
	return target_pos

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
	play_game()
