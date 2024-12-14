extends Label

@export var target: Node

func _process(_delta):
	text = target.State
