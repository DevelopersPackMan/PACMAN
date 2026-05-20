extends CharacterBody2D

# Nastavimo hitrost premikanja
@export var speed: float = 200.0

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	
	# Preverjanje vnosov (Pazi, da se črke natančno ujemajo z Input Mapom!)
	if Input.is_action_pressed("left"):
		direction.x = -1
	elif Input.is_action_pressed("right"):
		direction.x = 1
		
	if Input.is_action_pressed("up"):
		direction.y = -1
	elif Input.is_action_pressed("down"): # Popravljeno v veliko začetnico 'Down'
		direction.y = 1
	
	# Če se premikamo diagonalno, poskrbimo, da ne gremo prehitro
	if direction.length() > 0:
		direction = direction.normalized()
	
	# Izračun hitrosti in premik
	velocity = direction * speed
	move_and_slide()
