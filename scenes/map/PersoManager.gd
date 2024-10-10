extends Node2D

# Declare variables at the class level
var speed = 200  # Movement speed in pixels per second
var current_case = 0  # The player's position in the case array

# Reference to the TileMap for tile movement
onready var tile_map = $TileMap

# Function to move the player based on the number of dice steps
func move(steps):
	# Increment the player's current case
	current_case += steps
	
	# Get all the available tile positions (cases) from the tile map
	var cases = tile_map.get_used_cells()

	# Ensure the player doesn't move past the last tile
	if current_case >= cases.size():
		current_case = cases.size() - 1  # Stop at the last case if they go out of bounds
	
	# Find the world position of the target tile
	var target_position = tile_map.map_to_world(cases[current_case])
	
	# Move the player to the new position
	move_to(target_position)

# Function to move the player smoothly to the target position (you can expand this)
func move_to(target_position):
	# Move the player directly to the target tile (you can add a tween for smooth movement)
	position = target_position
	print("Player ", name, " moved to case ", current_case)
	
	# Optionally, you can check the type of case (e.g., bonus, trap)
	check_case()

# Function to check the tile after moving (for bonuses or disadvantages)
func check_case():
	var current_tile = tile_map.get_cellv(tile_map.world_to_map(position))
	
	# Check if the player landed on a bonus or trap tile
	if current_tile == BONUS_TILE_ID:  # Replace with actual bonus tile ID
		print("Player ", name, " landed on a bonus tile!")
		# Apply bonus effect (e.g., extra steps)
	elif current_tile == TRAP_TILE_ID:  # Replace with actual trap tile ID
		print("Player ", name, " landed on a trap tile!")
		# Apply trap effect (e.g., lose steps)
