 
extends CharacterBody2D

class_name Agent_maitresse

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Variables pour le comportement de la maîtresse
var time_to_turn_back: float = 0
var time_to_turn_front: float = 0
var facing_blackboard: bool = true

# Définir la méthode pour choisir un temps aléatoire entre 4 et 10 secondes pour se tourner vers le tableau
func _random_turn_time():
	return randf_range(3.0, 10.0)

# Définir la méthode pour choisir un temps de surveillance aléatoire entre 1 et 3 secondes
func _random_front_time():
	return randf_range(1.0, 3.0)

# Fonction appelée au début, initialise le temps et joue l'animation de la maîtresse écrivant au tableau
func _ready():
	time_to_turn_back = _random_turn_time()
	animated_sprite_2d.play("back_idle")

# Fonction appelée chaque frame pour mettre à jour le comportement de la maîtresse
func _process(delta: float) -> void:
	# Si la maîtresse est face au tableau
	if facing_blackboard:
		time_to_turn_back -= delta
		if time_to_turn_back <= 0:
			# Se retourner pour surveiller les enfants
			_turn_towards_children()
			# Réinitialiser le temps de surveillance aléatoire
			time_to_turn_front = _random_front_time()
	else:
		time_to_turn_front -= delta
		if time_to_turn_front <= 0:
			# Se retourner pour écrire au tableau
			_turn_towards_blackboard()
			# Réinitialiser le temps aléatoire
			time_to_turn_back = _random_turn_time()

# Fonction pour se retourner et surveiller les enfants
func _turn_towards_children():
	facing_blackboard = false
	# Jouer l'animation de surveillance des enfants
	animated_sprite_2d.play("front_idle")
	print("La maîtresse se retourne pour surveiller les enfants")


# Fonction pour se retourner et écrire au tableau
func _turn_towards_blackboard():
	facing_blackboard = true
	# Jouer l'animation d'écriture au tableau
	animated_sprite_2d.play("back_idle")
	print("La maîtresse se retourne pour écrire au tableau")

# Fonction appelée lorsqu'un objet entre dans la zone de collision de la maîtresse
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is PickUpItem:
		area.queue_free()
