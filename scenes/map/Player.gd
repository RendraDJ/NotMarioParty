extends Node3D  # Or the appropriate type of your player

class_name Player

# Player variables
var current_tile: int = 0  # Track the current tile on the board
var is_moving: bool = false  # Flag to prevent other actions while moving

# Move the player to the target tile
func move_to_tile(target_tile: int, board_tiles: Array) -> void:
	if is_moving:
		return  # If already moving, prevent new moves
	
	is_moving = true
	var move_count = target_tile - current_tile  # Number of steps to take
	var steps_taken = 0
	
	# Move step by step
	while steps_taken < move_count:
		await move_to_position(board_tiles[current_tile])
		current_tile += 1
		steps_taken += 1

	is_moving = false

# Coroutine to move the player smoothly from one tile to the next
func move_to_position(target_pos: Vector3) -> void:
	var tween = get_tree().create_tween()  # Create a tween for movement animation
	tween.tween_property(self, "translation", target_pos, 1.0)  # Adjust the duration as needed
	await tween.finished  # Wait until the tween finishes before proceeding
