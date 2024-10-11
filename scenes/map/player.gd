extends Node2D

# List of allowed movement tiles
var allowed_tiles: Array = [
	Vector2(11, 18),
	Vector2(11, 16),
	Vector2(11, 14),
	Vector2(11, 12),
	Vector2(13, 12),
	Vector2(15, 12),
	Vector2(17, 12),
	Vector2(21, 12),
	Vector2(23, 12),
	Vector2(24, 10),
	Vector2(24, 8),
	Vector2(24, 6),
	Vector2(24, 4),
	Vector2(24, 2),
	Vector2(24, 0),
	Vector2(22, 0),
	Vector2(20, 0),
	Vector2(18, 0),
	Vector2(16, 0),
	Vector2(14, 0),
	Vector2(12, 0),
	Vector2(10, 2),
	Vector2(8, 4),
	Vector2(6, 6),
	Vector2(4, 6),
	Vector2(3, 8),
	Vector2(1, 8),
	Vector2(1, 10),
	Vector2(1, 12),
	Vector2(1, 14),
	Vector2(3, 14),
	Vector2(5, 14),
	Vector2(6, 14),
	Vector2(9, 14)  # Add your specific yellow tiles
]

# Reference to the groud TileMapLayer
#@onready var ground_layer = get_node("../ground")  # Access the specific TileMapLayer named "groud
@onready var ground_layer : TileMapLayer = $ground
# Player's current position in tile coordinates
var current_tile: Vector2 = Vector2(11, 18)  # Starting tile
var tile_size: Vector2 = Vector2(32, 32)  # Set the tile size to whatever your tiles are

func _ready():
	set_position_to_tile(current_tile)
	print("Player starting position set to:", current_tile)

func roll_dice():
	# Simulating a dice roll between 1 and 6
	var dice_roll = randi() % 6 + 1
	print("Rolled: ", dice_roll)

	# Move to a new tile based on the rolled value
	move_player(dice_roll)

func move_player(dice_value: int):
	# Calculate potential new tile position
	var new_tile = current_tile + Vector2(dice_value, 0)

	# Check if the new tile is in the allowed tiles
	if allowed_tiles.find(new_tile) != -1:
		current_tile = new_tile  # Update to the new tile
		print("Moving player to tile:", current_tile)
		set_position_to_tile(current_tile)
	else:
		print("Cannot move to this tile:", new_tile)

func set_position_to_tile(tile_position: Vector2):
	position = tile_position * tile_size  # Set the player's position based on the tile size
