extends Node

var tile_coordinates = [
	Vector2(377,587), Vector2(368,517), Vector2(368,452),
	Vector2(368,388), Vector2(432,388), Vector2(495,388),
	Vector2(558,388), Vector2(623,388), Vector2(689,388),
	Vector2(752,388), Vector2(784,321), Vector2(784,259),
	Vector2(784,196), Vector2(784,132), Vector2(784,67),
	Vector2(784,4), Vector2(720,4), Vector2(655,4),
	Vector2(592,4), Vector2(529,4), Vector2(463,4),
	Vector2(399,4), Vector2(336,68), Vector2(271,133),
	Vector2(208,196), Vector2(144,196), Vector2(111,259),
	Vector2(48,259), Vector2(48,324), Vector2(48,388),
	Vector2(48,452), Vector2(110,452), Vector2(175,452),
	Vector2(239,452), Vector2(306,452), Vector2(368,452)
]

# Set a delay for movement
var move_delay = 0.3

# Function to move the player along the path
func move_player(player: Node2D, start_pos: int, steps: int) -> int:
	var target_pos = min(start_pos + steps, tile_coordinates.size())
	for i in range(start_pos, target_pos):
		await get_tree().create_timer(move_delay).timeout
		player.position = tile_coordinates[i]
	return target_pos
