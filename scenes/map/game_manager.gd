extends Node

# References to the players
var players = []
var current_player_index: int = 0
var board_tiles = []  # This will contain the positions of each tile on the board

# Number of players
const TOTAL_PLAYERS = 2

# Initialize the game manager
func _ready():
	# Add player nodes (assume they are named "Player1", "Player2", etc.)
	players.append($player1)
	players.append($player2)

	# Define the positions of each tile (example positions)
	board_tiles = [
		Vector3(3.925, 0.165, 0),  # Tile 1
		Vector3(5.904, 0.165, 0),  # Tile 2
		Vector3(7.889, 0.165, 0),  # Tile 3
		Vector3(9.876, 0.165, 0),  # Tile 4
		Vector3(11.83, 0, 0),  # Tile 5
		# Continue to define the rest of your board positions here
	]
	
	# Start the game
	roll_for_turn_order()

# Determine which player starts by rolling the dice
func roll_for_turn_order():
	var player1_roll = roll_dice()
	var player2_roll = roll_dice()
	
	print("Player 1 rolled: ", player1_roll)
	print("Player 2 rolled: ", player2_roll)
	
	if player1_roll > player2_roll:
		current_player_index = 0
		print("Player 1 starts!")
	else:
		current_player_index = 1
		print("Player 2 starts!")
	
	await start_turn(current_player_index)

# Roll a dice (6-sided)
func roll_dice() -> int:
	return randi() % 6 + 1  # Returns a number between 1 and 6

# Start the current player's turn
func start_turn(player_index: int) -> void:
	print("Player ", player_index + 1, "'s turn")

	# Roll the dice and move the player
	var roll = roll_dice()
	print("Player ", player_index + 1, " rolled a ", roll)
	
	var player = players[player_index]
	var new_tile = player.current_tile + roll
	
	# Prevent going off the board
	if new_tile >= board_tiles.size():
		new_tile = board_tiles.size() - 1
	
	# Move the player to the new tile
	await player.move_to_tile(new_tile, board_tiles)
	
	# After the move, switch to the next player
	end_turn()

# End the current player's turn and switch to the next player
func end_turn():
	current_player_index = (current_player_index + 1) % TOTAL_PLAYERS
	start_turn(current_player_index)
