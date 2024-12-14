extends CharacterBody2D

class_name AgentEleve2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const speed: float = 50.0

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction:
		velocity = direction * speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		velocity.y = move_toward(velocity.y, 0, speed * delta)
	move_and_slide()
	
	if velocity != Vector2.ZERO:
		animated_sprite_2d.play_movement_animation(velocity)
	else:
		animated_sprite_2d.play_idle_animation()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is PickUpItem:
		area.queue_free()
		
func _ready() -> void:
	randomize()
	_start_random_movement()

func _start_random_movement() -> void:
	var random_direction = Vector2()
	if randi() % 2 == 0:
		random_direction.x = randf_range(-1, 1)
	else:
		random_direction.y = randf_range(-1, 1)
	random_direction = random_direction.normalized()
	velocity = random_direction * speed
	await get_tree().create_timer(randf_range(1, 3)).timeout
	_start_random_movement()
