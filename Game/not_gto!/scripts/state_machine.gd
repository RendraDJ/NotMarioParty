extends Node

class_name StateMachine

@onready var parent = get_parent()
@export var loadedStates: Array[StringName]

var state: StringName
var previousState = null
var states: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for state in loadedStates:
		add_state(state)
	call_deferred("set_state", loadedStates[0])

func _get_ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if state != null:
		var transition = _get_transition(delta)
		if transition != null:
			_set_state(transition)

func _state_logic(_delta: float) -> void:
	pass

func _get_transition(_delta):
	return null

func _enter_state(_newState, _oldState) -> void:
	pass

func _exit_state(_oldState, _newState) -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
