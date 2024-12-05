extends Node2D

class_name Player

@export var player_name: String = "Unnamed Player"
var coins: int = 0
var stars: int = 0
var tile_index: int = 0

var score_label: Label
var game_manager: Node

func move(tile_coordinates: Array, steps: int, move_delay: float) -> void:
	game_manager.log_message(player_name + " rolls a " + str(steps) + " and moves.")
	var target_index = min(tile_index + steps, tile_coordinates.size() - 1)
	for i in range(tile_index + 1, target_index + 1):
		await get_tree().create_timer(move_delay).timeout
		global_position = tile_coordinates[i]
		tile_index = i
	game_manager.log_message(player_name + " landed on tile " + str(tile_index) + ".")

func gain_coins(amount: int):
	coins += amount
	coins = max(coins, 0)
	game_manager.log_message(player_name + " now has " + str(coins) + " coins.")
	_update_ui()

func gain_star():
	stars += 1
	game_manager.log_message(player_name + " now has " + str(stars) + " stars.")
	_update_ui()

func _update_ui():
	if score_label:
		score_label.text = player_name + ": Coins = " + str(coins) + ", Stars = " + str(stars)
