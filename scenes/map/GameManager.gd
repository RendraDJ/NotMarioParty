extends Node2D

# Class variables
var player_positions: Dictionary = { "player1": 0, "player2": 0 }  # Store index of current tile positions for both players
var current_player: String = "player1"  # Keep track of whose turn it is

# Define valid tile coordinates (0-indexed)
var valid_tiles: Array = [
	Vector2(2, 5),  # Tile 1
	Vector2(2, 2),  # Tile 2
	Vector2(2, -1),  # Tile 3
	Vector2(0, -4),  # Tile 4
	Vector2(-2, -7),  # Tile 5
	Vector2(-5, -8),  # Tile 6
	Vector2(-4, -11),  # Tile 7
	# Add more tiles as needed
]

# Reference to your TileMap
@onready var tile_map: TileMapLayer = $GROUND  # Adjust the path if necessary

# Reference to the player nodes
@onready var player1: Node2D = $perso1  # Adjust the path if necessary
@onready var player2: Node2D = $perso2  # Adjust the path if necessary

# Function to roll the dice
func roll_dice() -> int:
	var dice_value: int = randi() % 6 + 1  # Generate random number between 1 and 6
	print("Rolled dice: ", dice_value)
	return dice_value

# Function to move the player based on dice roll
func move_player(player: String, steps: int) -> void:
	var current_index: int = player_positions[player]  # Get current tile index
	var next_index: int = current_index + steps  # Calculate the next tile index

	# Check if the next index is within valid tiles
	if next_index < valid_tiles.size():
		player_positions[player] = next_index  # Update player position

		# Get the tile coordinates
		var tile_coords: Vector2 = valid_tiles[next_index]
		
		# Move the player to the corresponding world position
		var world_position: Vector2 = tile_map.map_to_world(tile_coords)
		
		# Set the position of the corresponding player node
		if player == "player1":
			player1.position = world_position
		elif player == "player2":
			player2.position = world_position

		print(player, " moved to tile: ", next_index)
	else:
		print("Invalid move for ", player)

# Start the game by rolling for both players
func _ready() -> void:
	# Roll the dice for player 1
	var dice_value_player1: int = roll_dice()
	move_player("player1", dice_value_player1)

	# Roll the dice for player 2
	var dice_value_player2: int = roll_dice()
	move_player("player2", dice_value_player2)
