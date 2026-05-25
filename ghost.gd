extends Area2D
class_name Ghost

enum GhostState {
	SCATTER, 
	CHASE, 
	RUN_AWAY,
	EATEN, 
	STARTING_AT_HOME
}

signal direction_change(current_direction: String)

var current_scatter_index = 0
var current_at_home_index = 0
var game_over = false
var direction = "right"
var current_state: GhostState
var is_blinking = false

@export var respawn_home_target: Node2D
@export var at_home_targets: Array[Node2D] = []
@export var scatter_targets: Array[Node2D] = []
@export var eaten_speed = 240
@export var speed = 120
@export var movement_targets: Node2D 
@export var color: Color
@export var chasing_target: Node2D
@export var points_manager: PointsManager
@export var is_starting_at_home = false 

@onready var at_home_timer = $AtHomeTimer
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
	if current_state != GhostState.EATEN and not run_away_timer.is_stopped() and run_away_timer.time_left < (run_away_timer.wait_time / 2) and not is_blinking: 
		start_blinking()
		
	if game_over:
		return
		
	if current_state == GhostState.CHASE and chasing_target == null:
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

	var velocity = move_direction * current_speed
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
	if is_starting_at_home: 
		start_at_home()
	else: 
		start_scatter_loop()

func start_at_home(): 
	current_state = GhostState.STARTING_AT_HOME
	at_home_timer.start()
	
	if at_home_targets.size() > current_at_home_index and is_instance_valid(at_home_targets[current_at_home_index]):
		navigation_agent_2d.target_position = at_home_targets[current_at_home_index].global_position

func update_navigation_target():
	if current_state == GhostState.EATEN:
		return 
		
	if scatter_targets.size() > 0 and current_scatter_index < scatter_targets.size():
		var target_marker = scatter_targets[current_scatter_index]
		if is_instance_valid(target_marker):
			navigation_agent_2d.target_position = target_marker.global_position
	
func start_scatter_loop():
	if current_state == GhostState.EATEN:
		return
		
	current_state = GhostState.SCATTER
	if update_chasing_target_position_timer != null:
		update_chasing_target_position_timer.stop()
		
	scatter_timer.start()
	
	if game_over:
		return
		
	update_navigation_target()
	backup_timer.start()

func on_position_reached():
	if current_state == GhostState.SCATTER: 
		scatter_position_reached()
	elif current_state == GhostState.RUN_AWAY: 
		run_away_from_pacman()
	elif current_state == GhostState.EATEN:
		check_if_home_reached()
	elif current_state == GhostState.STARTING_AT_HOME: 
		move_to_next_home_position()

func move_to_next_home_position(): 
	current_at_home_index = 1 if current_at_home_index == 0 else 0
	
	if at_home_targets.size() > current_at_home_index and is_instance_valid(at_home_targets[current_at_home_index]):
		navigation_agent_2d.target_position = at_home_targets[current_at_home_index].global_position

func scatter_position_reached(): 
	if current_state == GhostState.EATEN: 
		return
		
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

func _on_scatter_timer_timeout() -> void:
	if current_state != GhostState.RUN_AWAY and current_state != GhostState.EATEN:
		start_chasing_pacman()

func trigger_run_away():
	if game_over or current_state == GhostState.EATEN:
		return
		
	current_state = GhostState.RUN_AWAY
	is_blinking = false
	run_away_from_pacman()

func start_chasing_pacman(): 
	if current_state == GhostState.EATEN:
		return
		
	if chasing_target == null: 
		start_scatter_loop()
		return
		
	body_sprite.modulate = color
	if body_sprite.animation_player:
		body_sprite.animation_player.play("moving")
	eyes_sprite.show_eyes()
		
	current_state = GhostState.CHASE
	navigation_agent_2d.target_position = chasing_target.global_position
	
	if update_chasing_target_position_timer != null:
		update_chasing_target_position_timer.start()

func start_chasing_pacman_after_being_eaten():
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	
	body_sprite.show()
	body_sprite.move()
	body_sprite.modulate = color 
	
	start_chasing_pacman()
	
func _on_update_chasing_target_position_timer_timeout():
	if game_over or current_state == GhostState.RUN_AWAY or current_state == GhostState.EATEN:
		return
		
	if chasing_target != null and current_state == GhostState.CHASE:
		navigation_agent_2d.target_position = chasing_target.global_position
		update_chasing_target_position_timer.start()
	else:
		start_scatter_loop()

func run_away_from_pacman(): 
	if current_state == GhostState.EATEN:
		return

	if run_away_timer.is_stopped(): 
		body_sprite.run_away()
		eyes_sprite.hide_eyes()
		run_away_timer.wait_time = 8.0
		run_away_timer.start()
	
		if update_chasing_target_position_timer != null:
			update_chasing_target_position_timer.stop()
		scatter_timer.stop()

	if movement_targets != null:
		navigation_agent_2d.target_position = movement_targets.global_position
		
	backup_timer.start()
	
func start_blinking(): 
	is_blinking = true
	body_sprite.start_blinking()
	
func _on_run_away_timer_timeout() -> void:
	if current_state == GhostState.EATEN:
		return
	is_blinking = false
	eyes_sprite.show_eyes()
	body_sprite.move() 
	start_chasing_pacman()
	
func get_eaten():
	current_state = GhostState.EATEN
	
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	if body_sprite:
		body_sprite.hide()
	if eyes_sprite:
		eyes_sprite.show_eyes()   
		eyes_sprite.show()        
	
	if point_label:
		point_label.show()
	
	run_away_timer.stop()
	scatter_timer.stop()
	if update_chasing_target_position_timer != null:
		update_chasing_target_position_timer.stop()
		
	if points_manager:
		await points_manager.pause_on_ghost_eaten()
		
	if point_label:
		point_label.hide()
	
	if is_instance_valid(respawn_home_target):
		navigation_agent_2d.target_position = respawn_home_target.global_position
	else:
		start_scatter_loop()
		return
		
	backup_timer.start()

func check_if_home_reached():
	if current_state != GhostState.EATEN:
		return

	if is_instance_valid(respawn_home_target):
		var home_pos = respawn_home_target.global_position
		
		if global_position.distance_to(home_pos) < 20.0:
			backup_timer.stop()
			start_chasing_pacman_after_being_eaten()
		else:
			navigation_agent_2d.target_position = home_pos
			backup_timer.start()
	else:
		start_scatter_loop()
		
func _on_body_entered(body):
	if game_over or current_state == GhostState.EATEN:
		return
		
	var player = body as Player
	if player == null:
		return

	if current_state == GhostState.RUN_AWAY:
		get_eaten()
		return 
		
	elif current_state == GhostState.CHASE or current_state == GhostState.SCATTER:
		set_collision_mask_value(1, false)
		if update_chasing_target_position_timer != null:
			update_chasing_target_position_timer.stop()
		player.die()
		scatter_timer.wait_time = 600
		start_scatter_loop()
