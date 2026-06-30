extends CharacterBody2D
class_name Player

signal player_died(life: int)

# --- SPREMENLJIVKE ZA PREMIKANJE ---
var next_movement_direction = Vector2.ZERO
var movement_direction = Vector2.ZERO
var shape_query = PhysicsShapeQueryParameters2D.new()

# --- EXPORT SPREMENLJIVKE ---
@export var speed = 300
@export var power_pellet_sound: AudioStreamPlayer2D
@export var start_position: Node2D
@export var pacman_death_sound_player: AudioStreamPlayer2D
@export var lifes: int = 3
@export var eat_ghost_sound: AudioStreamPlayer2D
@export var pacman_chomp: AudioStreamPlayer2D

# --- ONREADY VOZLIŠČA ---
@onready var sprite_2d = $Sprite2D
@onready var pattern_sprite = $Sprite2D/Pattern
@onready var collision_shape_2d = $CollisionShape2D
@onready var animation_player = $AnimationPlayer

# --- SEZNAM SLIK ZA VZORCE (vsak vzorec ima 3 frame-e, usklajene z usti pacmana) ---
# pattern_textures[vzorec][frame] - vzorec: 0=brez, 1=pike, 2=proge, 3=srca, 4=zvezdice; frame: 0,1,2
var pattern_textures = [
	[null, null, null], # 0 = brez
	[
		preload("res://Resources/Graphics/Patterns/pike_01.png"),
		preload("res://Resources/Graphics/Patterns/pike_02.png"),
		preload("res://Resources/Graphics/Patterns/pike_03.png")
	], # 1 = pike
	[
		preload("res://Resources/Graphics/Patterns/proge_01.png"),
		preload("res://Resources/Graphics/Patterns/proge_02.png"),
		preload("res://Resources/Graphics/Patterns/proge_03.png")
	], # 2 = proge
	[
		preload("res://Resources/Graphics/Patterns/srca_01.png"),
		preload("res://Resources/Graphics/Patterns/srca_02.png"),
		preload("res://Resources/Graphics/Patterns/srca_03.png")
	], # 3 = srca
	[
		preload("res://Resources/Graphics/Patterns/zvezdice_01.png"),
		preload("res://Resources/Graphics/Patterns/zvezdice_02.png"),
		preload("res://Resources/Graphics/Patterns/zvezdice_03.png")
	], # 4 = zvezdice
]

# Slike telesa - uporabimo za prepoznavo, kateri animacijski frame je trenutno prikazan
var body_frame_textures = [
	preload("res://Resources/Graphics/Pacman_01.png"),
	preload("res://Resources/Graphics/Pacman_02.png"),
	preload("res://Resources/Graphics/Pacman_03.png")
]

func _ready():
	# 1. "Oblečemo" Pacmana (tvoj lik) takoj ob zagonu
	apply_custom_look()
	
	# 2. Nastavimo fiziko
	shape_query.shape = collision_shape_2d.shape
	shape_query.collision_mask = 2
	shape_query.exclude = [self.get_rid()] 
	
	# 3. Zaženemo animacijo
	if animation_player.has_animation("Defoult"):
		animation_player.play("Defoult")

# FUNKCIJA ZA NASTAVITEV VIDEZA (IZ OMARE)
func apply_custom_look():
	# 1. NASTAVI BARVO (Spreminjamo Pacmana na tisto, kar si izbrala)
	var colors = [
		Color(1.00, 1.00, 0),  # 1  Rumena
		Color(1.00, 0.78, 0),  # 2  Zlata
		Color(1.00, 0.55, 0),  # 3  Oranžna
		Color(1.00, 0.32, 0),  # 4  Temna oranžna
		Color(1.00, 0.08, 0),  # 5  Rdeča
		Color(0.60, 0.0, 0),   # 6  Temno rdeča
		Color(0.55, 0.50, 0),  # 7  Olivna
		Color(0.62, 1.00, 0),  # 8  Limeta
		Color(0.32, 1.00, 0),  # 9  Travnata zelena
		Color(0.08, 1.00, 0),  # 10 Zelena
		Color(0.0, 0.45, 0),   # 11 Temno zelena
		Color(0.40, 0.35, 0),  # 12 Kaki
		Color(0.85, 0.95, 0),  # 13 Peščena
		Color(0.95, 0.60, 0),  # 14 Bledo zlata
		Color(0.15, 0.20, 0),  # 15 Mahovita
	]
	var pac_color = Color(1, 1, 0) # Privzeto rumena
	if GlobalSettings.selected_ghost >= 1 and GlobalSettings.selected_ghost <= colors.size():
		pac_color = colors[GlobalSettings.selected_ghost - 1]
	
	sprite_2d.self_modulate = pac_color
	
	# 2. NASTAVI VZOREC (pattern) - frame 0 (zaprta usta) kot zacetna slika
	if pattern_sprite != null and GlobalSettings.selected_pattern < pattern_textures.size():
		pattern_sprite.texture = pattern_textures[GlobalSettings.selected_pattern][0]

func _process(_delta):
	# Uskladimo vzorec z animacijo ust (telo menja teksturo Pacman_01/02/03, vzorec mora slediti)
	if pattern_sprite == null: return
	if GlobalSettings.selected_pattern == 0: return
	var current_body_tex = sprite_2d.texture
	for i in range(body_frame_textures.size()):
		if current_body_tex == body_frame_textures[i]:
			pattern_sprite.texture = pattern_textures[GlobalSettings.selected_pattern][i]
			break

func reset_player():
	if animation_player.has_animation("Defoult"):
		animation_player.play("Defoult")
	
	if start_position != null:
		position = start_position.position
	
	set_physics_process(true)
	next_movement_direction = Vector2.ZERO
	movement_direction = Vector2.ZERO

func eat_power_pellet():
	if power_pellet_sound != null:
		power_pellet_sound.play()

func eat_ghost():
	if eat_ghost_sound != null:
		eat_ghost_sound.play()
	
func _physics_process(delta):
	get_input()
	if movement_direction == Vector2.ZERO:
		movement_direction = next_movement_direction
	if can_move_in_direction(next_movement_direction, delta):
		movement_direction = next_movement_direction
	if can_move_in_direction(movement_direction, delta):
		velocity = movement_direction * speed
	else:
		velocity = Vector2.ZERO
	
	# Zvok hrustanja
	if velocity != Vector2.ZERO:
		if pacman_chomp != null and !pacman_chomp.playing:
			pacman_chomp.play()
	else:
		if pacman_chomp != null:
			pacman_chomp.stop()
			
	move_and_slide()

func get_input():
	if Input.is_action_pressed("left"):
		next_movement_direction = Vector2.LEFT
		sprite_2d.rotation_degrees = 180
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
	if pacman_chomp != null: pacman_chomp.stop()
	if pacman_death_sound_player != null: pacman_death_sound_player.play()
	
	set_physics_process(false)
	lifes -= 1
	player_died.emit(lifes)
	if lifes > 0:
		reset_player()
	else:
		if animation_player.has_animation("death"):
			animation_player.play("death")
