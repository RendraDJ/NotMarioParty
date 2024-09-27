extends Sprite2D

func _ready():
	# Cacher l'image et la rendre transparente au lancement
	visible = false
	modulate.a = 0.0  # Réglez l'opacité de l'image à 0
	
	# Créer un Timer pour retarder l'apparition
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true  # Le timer se déclenche une seule fois
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()

func _on_timer_timeout():
	# Rendre l'image visible
	visible = true
	
	# Créer un Tween pour l'animation d'apparition
	var tween = get_tree().create_tween()
	
	# Animer l'opacité de 0 à 1 sur une durée de 1 seconde
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
