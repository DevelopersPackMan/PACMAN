extends Area2D
class_name Ghost

signal direction_change(current_direction: String)

var current_scatter_index = 0
var game_over = false
var direction = null

var scatter_targets: Array[Vector2] = [
	Vector2(12, 9),
	Vector2(22, 9),
	Vector2(22, 17),
	Vector2(12, 17)
]

@export var speed = 120
@export var tile_map: TileMap
@export var color: Color

@onready var navigation_agent_2d = $NavigationAgent2D
@onready var body_sprite = $BodySprite

# Časovanik, ki reši duhca, če se nekje zatakne
var backup_timer: Timer

func _ready():
	# Povečala bova razdaljo, da agent lažje zazna, ko je "blizu" točke
	navigation_agent_2d.path_desired_distance = 15.0
	navigation_agent_2d.target_desired_distance = 15.0
	navigation_agent_2d.target_reached.connect(on_position_reached)
	
	# Ustvarimo skriti časovnik za vsak slučaj
	backup_timer = Timer.new()
	backup_timer.wait_time = 4.0 # Če po 4 sekundah ne doseže točke, gre naprej
	backup_timer.one_shot = true
	backup_timer.timeout.connect(on_position_reached)
	add_child(backup_timer)
	
	call_deferred("setup")
	
func _physics_process(delta):
	if not game_over and navigation_agent_2d.get_navigation_map() != RID():
		# Navigacija potrebuje stalno osveževanje cilja, da teče gladko
		update_navigation_target()
		
		if not navigation_agent_2d.is_navigation_finished():
			move_ghost(navigation_agent_2d.get_next_path_position(), delta)

func move_ghost(next_position: Vector2, delta: float):
	var current_ghost_position = global_position
	var move_direction = (next_position - current_ghost_position).normalized()
	
	calculate_direction(move_direction)
	
	var new_velocity = move_direction * speed * delta
	position += new_velocity
	
	navigation_agent_2d.velocity = new_velocity
		
func calculate_direction(move_direction: Vector2):
	var current_direction = direction
	
	if abs(move_direction.x) > abs(move_direction.y):
		if move_direction.x > 0.1:
			current_direction = "right"
		elif move_direction.x < -0.1:
			current_direction = "left"
	else:
		if move_direction.y > 0.1:
			current_direction = "down"
		elif move_direction.y < -0.1:
			current_direction = "up"
	
	if current_direction != direction and current_direction != null:
		direction = current_direction
		direction_change.emit(direction)
	
func setup():
	if tile_map == null:
		print("NAPAKA: TileMap ni nastavljen v Inspectorju duhca!")
		return
		
	var nav_map = tile_map.get_navigation_map(0)
	navigation_agent_2d.set_navigation_map(nav_map)
	NavigationServer2D.agent_set_map(navigation_agent_2d.get_rid(), nav_map)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	start_scatter_loop()

func update_navigation_target():
	if scatter_targets.size() > 0:
		var tile_coords = scatter_targets[current_scatter_index]
		var global_pixels = (tile_coords * 24) + Vector2(12, 12)
		navigation_agent_2d.target_position = global_pixels
	
func start_scatter_loop():
	if game_over:
		return
		
	update_navigation_target()
	print("Duhec potuje proti indeksu: ", current_scatter_index, " (Koordinate: ", scatter_targets[current_scatter_index], ")")
	
	backup_timer.start()

func on_position_reached():
	if game_over:
		return
		
	backup_timer.stop()
	
	if scatter_targets.size() > 0:
		current_scatter_index = (current_scatter_index + 1) % scatter_targets.size()
		print("🔄 TOČKA DOSEŽENA! Naslednji indeks v zanki: ", current_scatter_index)
		
		start_scatter_loop()

func stop_game(won: bool):
	game_over = true
	backup_timer.stop()
	if won:
		print("GAME WON: Pacman je pojedel vse pike!")
	else:
		print("GAME OVER: Duhec je ujel Pacmana!")
