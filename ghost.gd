extends Area2D
class_name Ghost

enum GhostState {
	SCATTER, 
	CHASE, 
	RUN_AWAY,
	EATEN
}

signal direction_change(current_direction: String)

var current_scatter_index = 0
var game_over = false
var direction = "right"
var current_state: GhostState
var is_blinking = false

var scatter_targets: Array[Vector2i] = [
	Vector2i(12, 9),
	Vector2i(22, 9),
	Vector2i(22, 17),
	Vector2i(12, 17)
]

@export var eaten_speed = 240
@export var speed = 120
@export var movement_targets: Resource 
@export var tile_map: MazeTileMap
@export var color: Color
@export var chasing_target: Node2D
@export var points_manager: PointsManager

@onready var eyes_sprite = $EyesSprite as EyeSprite
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var body_sprite = $BodySprite as BodySprite
@onready var scatter_timer = $ScatterTimer
@onready var update_chasing_target_position_timer = $UpdateChasingTargetPositionTimer 
@onready var run_away_timer = $RunAwayTimer
@onready var point_label: Label = $PointLabel


var backup_timer: Timer

func _ready():
	navigation_agent_2d.path_desired_distance = 8.0
	navigation_agent_2d.target_desired_distance = 8.0
	navigation_agent_2d.target_reached.connect(on_position_reached)
	
	backup_timer = Timer.new()
	backup_timer.wait_time = 5.0 
	backup_timer.one_shot = true
	backup_timer.timeout.connect(on_position_reached)
	add_child(backup_timer)
	
	call_deferred("setup")
	
func _physics_process(delta):
	# Preverjamo preostali čas: če teče in je pod polovico ter še ne utripa, sprožimo utripanje
	if not run_away_timer.is_stopped() and run_away_timer.time_left < (run_away_timer.wait_time / 2) and not is_blinking: 
		start_blinking()
		
	if game_over:
		return
		
	if current_state == GhostState.CHASE and chasing_target == null:
		print("Pacman ni najden! Duhec se vrača na patruliranje.")
		start_scatter_loop()
		return

	if navigation_agent_2d.is_navigation_finished():
		return
		
	var next_path_pos = navigation_agent_2d.get_next_path_position()
	move_ghost(next_path_pos, delta)

func move_ghost(next_position: Vector2, delta: float):
	var target_vector = next_position - global_position
	var current_speed = eaten_speed if current_state == GhostState.EATEN else speed
	
	if target_vector.length() < 1.0:
		return

	var move_direction = target_vector.normalized()
	
	var grid_direction = Vector2.ZERO
	if abs(target_vector.x) > abs(target_vector.y):
		grid_direction.x = sign(target_vector.x)
	else:
		grid_direction.y = sign(target_vector.y)
	calculate_direction(grid_direction)

	var velocity = move_direction * speed
	navigation_agent_2d.set_velocity(velocity)
	global_position += velocity * delta
		
func calculate_direction(move_direction: Vector2):
	var current_direction = direction
	
	if move_direction.x > 0:
		current_direction = "right"
	elif move_direction.x < 0:
		current_direction = "left"
	elif move_direction.y > 0:
		current_direction = "down"
	elif move_direction.y < 0:
		current_direction = "up"
	
	if current_direction != direction:
		direction = current_direction
		direction_change.emit(direction)
	
func setup():
	if tile_map == null:
		print("NAPAKA: TileMap ni nastavljen v Inspectorju duhca!")
		return
	
	var nav_map = tile_map.get_navigation_map(0)
	navigation_agent_2d.set_navigation_map(nav_map)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var current_tile = tile_map.local_to_map(tile_map.to_local(global_position))
	global_position = tile_map.to_global(tile_map.map_to_local(current_tile))
	
	start_scatter_loop()

func update_navigation_target():
	if scatter_targets.size() > 0 and tile_map != null:
		var tile_coords = scatter_targets[current_scatter_index]
		var local_pixels = tile_map.map_to_local(tile_coords)
		var global_pixels = tile_map.to_global(local_pixels)
		
		navigation_agent_2d.target_position = global_pixels
	
func start_scatter_loop():
	current_state = GhostState.SCATTER
	if update_chasing_target_position_timer != null:
		update_chasing_target_position_timer.stop()
		
	scatter_timer.start()
	
	if game_over:
		return
		
	update_navigation_target()
	print("Duhec patrulira proti celici: ", scatter_targets[current_scatter_index])
	
	backup_timer.start()

func on_position_reached():
	if current_state == GhostState.SCATTER: 
		scatter_position_reached()
	elif current_state == GhostState.CHASE: 
		chase_position_reached()
	elif current_state == GhostState.RUN_AWAY: 
		# Ko med begom doseže naključno točko, izbere naslednjo celico
		run_away_from_pacman()
	elif current_state == GhostState.EATEN:
		start_chasing_pacman_after_being_eaten()
		

func chase_position_reached(): 
	print("KILL PACMAN")
	
func scatter_position_reached(): 
	if current_scatter_index < scatter_targets.size() - 1: 
		current_scatter_index += 1
	else:	
		current_scatter_index = 0

	update_navigation_target()
	backup_timer.start()
					
func stop_game(won: bool):
	game_over = true
	backup_timer.stop()
	scatter_timer.stop()
	run_away_timer.stop()
	if update_chasing_target_position_timer != null:
		update_chasing_target_position_timer.stop()
		
	if won:
		print("GAME WON")
	else:
		print("GAME OVER")

func _on_scatter_timer_timeout() -> void:
	if current_state != GhostState.RUN_AWAY:
		start_chasing_pacman()

## TO FUNKCIJO POKLIČE KODA IGRE, KO PACMAN POJE VELIKO PIKO
func trigger_run_away():
	if game_over:
		return
		
	print("Sprožen beg preko velike pike!")
	current_state = GhostState.RUN_AWAY
	is_blinking = false # Ponastavimo utripanje za nov beg
	
	# Pokličemo funkcijo bega, ki bo takoj zamenjala grafiko in izbrala pot
	run_away_from_pacman()

func start_chasing_pacman(): 
	if chasing_target == null: 
		print("Pacman ni nastavljen. Duhec nadaljuje patruliranje po koordinatah.")
		start_scatter_loop()
		return
		
	# Ponastavimo originalni izgled duhca nazaj na njegove prave barve
	body_sprite.modulate = color
	body_sprite.animation_player.play("moving")
	eyes_sprite.show_eyes()
		
	current_state = GhostState.CHASE
	navigation_agent_2d.target_position = chasing_target.global_position
	
	if update_chasing_target_position_timer != null:
		update_chasing_target_position_timer.start()
		
	print("Duhec je uspešno zavil in začel loviti Pacmana!")
	
func _on_update_chasing_target_position_timer_timeout():
	if game_over or current_state == GhostState.RUN_AWAY:
		return
		
	if chasing_target != null and current_state == GhostState.CHASE:
		navigation_agent_2d.target_position = chasing_target.global_position
		update_chasing_target_position_timer.start()
	else:
		start_scatter_loop()

func start_chasing_pacman_after_being_eaten():
	start_chasing_pacman()
	body_sprite.show()
	body_sprite.move()

func run_away_from_pacman(): 
	# POPRAVEK: Sprememba barve in skrivanje oči se zgodita TAKOJ, ko se časovnik zažene
	if run_away_timer.is_stopped(): 
		body_sprite.run_away()
		eyes_sprite.hide_eyes()
		run_away_timer.wait_time = 8.0
		run_away_timer.start()
	
		if update_chasing_target_position_timer != null:
			update_chasing_target_position_timer.stop()
		scatter_timer.stop()

	if tile_map == null:
		return

	var tile = tile_map.get_random_empty_cell_position()
	var local_pixels = tile_map.map_to_local(tile)
	var global_pixels = tile_map.to_global(local_pixels)

	navigation_agent_2d.target_position = global_pixels
	backup_timer.start()
	
func start_blinking(): 
	is_blinking = true
	body_sprite.start_blinking()
	
func _on_run_away_timer_timeout() -> void:
	is_blinking = false
	eyes_sprite.show_eyes()
	body_sprite.move() 
	start_chasing_pacman()
	
func get_eaten():
	body_sprite.hide()
	point_label.show()
	eyes_sprite.show_eyes()
	await points_manager.pause_on_ghost_eaten()
	point_label.hide()
	run_away_timer.stop()
	current_state = GhostState.EATEN
	navigation_agent_2d.target_position = movement_targets.at_home_targets[0].position


func _on_body_entered(body):
	var player = body as Player
	if current_state == GhostState.RUN_AWAY:
		get_eaten()
	elif current_state == GhostState.CHASE || current_state == GhostState.SCATTER:
		set_collision_mask_value(1, false)
		update_chasing_target_position_timer.stop()
		player.die()
		scatter_timer.wait_time = 600
		start_scatter_loop()
