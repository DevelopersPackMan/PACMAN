extends CharacterBody2D

class_name Player

signal player_died(life: int)

# Variables
var next_movement_direction = Vector2.ZERO
var movement_direction = Vector2.ZERO
var shape_query = PhysicsShapeQueryParameters2D.new()

# Export variables
@export var speed = 300
@export var start_position: Node2D # To moraš nastaviti v Inspectorju!
@export var pacman_death_sound_player: AudioStreamPlayer2D
@export var lifes: int = 2

# Onready variables
@onready var sprite_2d = $Sprite2D # Preveri, če se tvoj node imenuje Sprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var animation_player = $AnimationPlayer

func _ready():
	shape_query.shape = collision_shape_2d.shape
	shape_query.collision_mask = 2
	shape_query.exclude = [self.get_rid()] 
	animation_player.play("Defoult")

func reset_player():
	if animation_player.has_animation("Default"):
		animation_player.play("Default")
	
	# Če si pozabila nastaviti start_position v Inspectorju, se igra ne bo sesula:
	if start_position != null:
		position = start_position.position
	else:
		print("OPOZORILO: Start Position ni nastavljen v Inspectorju!")
	
	set_physics_process(true)
	next_movement_direction = Vector2.ZERO
	movement_direction = Vector2.ZERO
	
func _physics_process(delta):
	get_input()
	
	# Logika za premikanje in zavijanje
	if movement_direction == Vector2.ZERO:
		movement_direction = next_movement_direction
		
	if can_move_in_direction(next_movement_direction, delta):
		movement_direction = next_movement_direction
	
	if can_move_in_direction(movement_direction, delta):
		velocity = movement_direction * speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

func get_input():
	if Input.is_action_pressed("left"):
		next_movement_direction = Vector2.LEFT
		sprite_2d.rotation_degrees = 180 # Rotiramo samo sliko, ne celega telesa
	elif Input.is_action_pressed("right"):
		next_movement_direction = Vector2.RIGHT
		sprite_2d.rotation_degrees = 0
	elif Input.is_action_pressed("down"):
		next_movement_direction = Vector2.DOWN
		sprite_2d.rotation_degrees = 90
	elif Input.is_action_pressed("up"):
		next_movement_direction = Vector2.UP
		sprite_2d.rotation_degrees = 270

func can_move_in_direction(dir: Vector2, delta: float) -> bool:
	if dir == Vector2.ZERO: return false
	shape_query.transform = global_transform.translated(dir * speed * delta * 2)
	var result = get_world_2d().direct_space_state.intersect_shape(shape_query)
	return result.size() == 0	

func die():
	if pacman_death_sound_player != null and !pacman_death_sound_player.playing:
		pacman_death_sound_player.play()
	
	if animation_player.has_animation("death"):
		animation_player.play("death")
	
	set_physics_process(false)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "death":
		lifes -= 1
		player_died.emit(lifes)
		if lifes > 0:
			reset_player()
		else:
			if start_position != null:
				position = start_position.position
			set_collision_layer_value(1, false)
