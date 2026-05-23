extends Area2D

var current_scatter_index = 0
var game_over = false

@export var speed = 120
@export var movements_targets: MovementTargets
@export var tile_map: TileMap
@onready var navigation_agent_2d = $NavigationAgent2D

func _ready():
	navigation_agent_2d.path_desired_distance = 4.0
	navigation_agent_2d.target_desired_distance = 4.0
	navigation_agent_2d.target_reached.connect(on_position_reached)
	call_deferred("setup")
	
func _process(delta):
	if game_over: 
		return
		
	if navigation_agent_2d.is_navigation_finished():
		on_position_reached()
		return # Preskočimo ta okvir, da agent v ozadju uspešno osveži naslednjo pot
		
	# Premaknemo duhca po izrisani poti okoli stene
	var next_path_pos = navigation_agent_2d.get_next_path_position()
	move_ghost(next_path_pos, delta)
	
func move_ghost(next_position: Vector2, delta: float):
	var direction = (next_position - global_position).normalized()
	global_position += direction * speed * delta
		
func setup():
	if tile_map == null:
		print("NAPAKA: TileMap ni nastavljen na duhcu!")
		return
		
	var nav_map = tile_map.get_navigation_map(0)
	navigation_agent_2d.set_navigation_map(nav_map)
	NavigationServer2D.agent_set_map(navigation_agent_2d.get_rid(), nav_map)
	
	# Ročna nastavitev unikatnih koordinat za tega duhca v kodi
	if movements_targets:
		movements_targets.scatter_targets.clear() 	
		movements_targets.scatter_targets.append(Vector2(12, 9))
		movements_targets.scatter_targets.append(Vector2(22, 9))
		movements_targets.scatter_targets.append(Vector2(22, 17))
		movements_targets.scatter_targets.append(Vector2(12, 17))
		
		print("Koordinate uspešno nastavljene. Število točk: ", movements_targets.scatter_targets.size())

	# Počakamo, da se navigacija v ozadju sinhronizira
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# Zaženemo neskončno zanko premikanja
	start_scatter_loop()
	
func start_scatter_loop():
	if movements_targets and movements_targets.scatter_targets.size() > 0:
		var tile_coords = movements_targets.scatter_targets[current_scatter_index]
		var global_pixels = (tile_coords * 24) + Vector2(12, 12)
		
		navigation_agent_2d.target_position = global_pixels
		print("Duhec gre proti točki: ", tile_coords)
		
func on_position_reached(): 
	if game_over:
		return
		
	if movements_targets and movements_targets.scatter_targets.size() > 0:
		current_scatter_index = (current_scatter_index + 1) % movements_targets.scatter_targets.size()
		
		start_scatter_loop()
		print("Duhec je dosegel točko. Naslednja v zanki je indeks: ", current_scatter_index)

func stop_game(won: bool):
	game_over = true
	if won:
		print("GAME WON: Pacman je pojedel vse pike!")
	else:
		print("GAME OVER: Duhec je ujel Pacmana!")
