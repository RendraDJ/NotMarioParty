extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/startButton.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://scenes/character_selection/character_selection.tscn")

func _on_options_button_pressed() -> void:
	pass # Replace with function body.
	#get_tree().change_scene("")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
