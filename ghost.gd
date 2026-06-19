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
var sent_home_by_player = false

# Zastavica, ki med pavzo prepreči kakršnokoli premikanje
var is_paused_after_killing = false 

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
var is_leaving_home_after_eaten = false 

func _ready():
	navigation_agent_2d.path_desired_distance = 8.0
	navigation_agent_2d.target_desired_distance = 8.0
	navigation_agent_2d.target_reached.connect(on_position_reached)
	
	backup_timer = Timer.new()
	backup_timer.wait_time = 5.0 
	backup_timer.one_shot = true
	backup_timer.timeout.connect(on_position_reached)
	add_child(backup_timer)
	
	if at_home_timer:
		at_home_timer.timeout.connect(_on_at_home_timer_timeout)
	
	call_deferred("setup")
	
func _physics_process(delta):
	if game_over or is_paused_after_killing:
		return

	if current_state == GhostState.RUN_AWAY and not run_away_timer.is_stopped() and run_away_timer.time_left < (run_away_timer.wait_time / 2) and not is_blinking: 
		start_blinking()
		
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
	await get_tree().physics_frame
	
	if is_starting_at_home: 
		start_at_home()
	else: 
		start_scatter_loop()

func start_at_home(): 
	current_state = GhostState.STARTING_AT_HOME
	navigation_agent_2d.path_desired_distance = 2.0
	navigation_agent_2d.target_desired_distance = 2.0
	
	at_home_timer.start()
	
	if at_home_targets.size() > current_at_home_index and is_instance_valid(at_home_targets[current_at_home_index]):
		navigation_agent_2d.target_position = at_home_targets[current_at_home_index].global_position
		navigation_agent_2d.get_next_path_position()
		
func _on_at_home_timer_timeout() -> void:
	if current_state == GhostState.STARTING_AT_HOME and not is_leaving_home_after_eaten:
		if not run_away_timer.is_stopped():
			current_state = GhostState.RUN_AWAY
			run_away_from_pacman()
		else:
			leave_home_completely()

func leave_home_completely():
	if respawn_home_target and is_instance_valid(respawn_home_target):
		navigation_agent_2d.path_desired_distance = 4.0
		navigation_agent_2d.target_desired_distance = 4.0
		navigation_agent_2d.target_position = respawn_home_target.global_position
		navigation_agent_2d.get_next_path_position()
	else:
		is_leaving_home_after_eaten = false
		start_scatter_loop()

func update_navigation_target():
	if current_state == GhostState.EATEN or current_state == GhostState.STARTING_AT_HOME:
		return 
		
	if scatter_targets.size() > 0 and current_scatter_index < scatter_targets.size():
		var target_marker = scatter_targets[current_scatter_index]
		if is_instance_valid(target_marker):
			navigation_agent_2d.target_position = target_marker.global_position
			navigation_agent_2d.get_next_path_position()
	
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
		if is_leaving_home_after_eaten:
			is_leaving_home_after_eaten = false
			navigation_agent_2d.path_desired_distance = 8.0
			navigation_agent_2d.target_desired_distance = 8.0
			
			if not run_away_timer.is_stopped():
				current_state = GhostState.RUN_AWAY
				run_away_from_pacman()
			else:
				start_chasing_pacman()
		else:
			move_to_next_home_position()

func move_to_next_home_position(): 
	if at_home_targets.size() == 0:
		return
		
	current_at_home_index = (current_at_home_index + 1) % at_home_targets.size()
	
	var naslednja_tocka = at_home_targets[current_at_home_index]
	if is_instance_valid(naslednja_tocka):
		navigation_agent_2d.target_position = naslednja_tocka.global_position
		navigation_agent_2d.get_next_path_position()
		
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
	if current_state != GhostState.RUN_AWAY and current_state != GhostState.EATEN and current_state != GhostState.STARTING_AT_HOME:
		start_chasing_pacman()

func trigger_run_away():
	if game_over or current_state == GhostState.EATEN:
		return
	
	if body_sprite:
		body_sprite.run_away()
	if eyes_sprite:
		eyes_sprite.hide_eyes()
	
	is_blinking = false
	
	run_away_timer.wait_time = 8.0
	run_away_timer.start()

	if current_state == GhostState.STARTING_AT_HOME:
		return

	current_state = GhostState.RUN_AWAY
	run_away_from_pacman()

func start_chasing_pacman(): 
	if current_state == GhostState.EATEN or current_state == GhostState.STARTING_AT_HOME:
		return
		
	if chasing_target == null: 
		start_scatter_loop()
		return
		
	if body_sprite:
		body_sprite.modulate = color
		if body_sprite.animation_player:
			body_sprite.animation_player.play("moving")
	if eyes_sprite:
		eyes_sprite.show_eyes()
		
	current_state = GhostState.CHASE
	navigation_agent_2d.target_position = chasing_target.global_position
	navigation_agent_2d.get_next_path_position() 
	
	if update_chasing_target_position_timer != null:
		update_chasing_target_position_timer.start()

func start_chasing_pacman_after_being_eaten():
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	
	if body_sprite:
		body_sprite.show()
		if body_sprite.has_method("move"):
			body_sprite.move()
		body_sprite.modulate = color 
		
	if eyes_sprite:
		eyes_sprite.show_eyes()
		eyes_sprite.show()

	current_state = GhostState.STARTING_AT_HOME
	is_leaving_home_after_eaten = true
	leave_home_completely()
	
func _on_update_chasing_target_position_timer_timeout():
	if game_over or current_state == GhostState.RUN_AWAY or current_state == GhostState.EATEN or current_state == GhostState.STARTING_AT_HOME:
		return
		
	if chasing_target != null and current_state == GhostState.CHASE:
		navigation_agent_2d.target_position = chasing_target.global_position
		navigation_agent_2d.get_next_path_position()
		update_chasing_target_position_timer.start()
	else:
		start_scatter_loop()

func run_away_from_pacman(): 
	if current_state == GhostState.EATEN:
		return
	
	if update_chasing_target_position_timer != null:
		update_chasing_target_position_timer.stop()
	scatter_timer.stop()

	if movement_targets != null:
		navigation_agent_2d.target_position = movement_targets.global_position
		navigation_agent_2d.get_next_path_position()
		
	backup_timer.start()
	
func start_blinking(): 
	is_blinking = true
	if body_sprite and body_sprite.has_method("start_blinking"):
		body_sprite.start_blinking()
	
func _on_run_away_timer_timeout() -> void:
	if current_state == GhostState.EATEN or current_state == GhostState.STARTING_AT_HOME:
		return
		
	is_blinking = false
	if eyes_sprite:
		eyes_sprite.show_eyes()
	if body_sprite:
		if body_sprite.has_method("move"):
			body_sprite.move() 
			
	start_chasing_pacman()
	
func get_eaten():
	current_state = GhostState.EATEN
	print("Duh ", name, " je bil pojeden! Oči potujejo na prvo domačo točko.")
	
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
	
	if at_home_targets.size() > 0 and is_instance_valid(at_home_targets[0]):
		var cilj = at_home_targets[0].global_position
		navigation_agent_2d.path_desired_distance = 2.0
		navigation_agent_2d.target_desired_distance = 2.0
		navigation_agent_2d.target_position = cilj
		navigation_agent_2d.get_next_path_position()
		backup_timer.start()
	else:
		print("NAPAKA: Seznam 'at_home_targets' je prazen!")
		start_scatter_loop()

func check_if_home_reached():
	if current_state != GhostState.EATEN:
		return

	if at_home_targets.size() > 0 and is_instance_valid(at_home_targets[0]):
		var home_pos = at_home_targets[0].global_position
		var razdalja = global_position.distance_to(home_pos)
		
		if razdalja < 8.0:
			backup_timer.stop()
			start_chasing_pacman_after_being_eaten()
		else:
			navigation_agent_2d.target_position = home_pos
			navigation_agent_2d.get_next_path_position()
			backup_timer.start()
	else:
		start_scatter_loop()
		
func _on_body_entered(body):
	if game_over or current_state == GhostState.EATEN or current_state == GhostState.STARTING_AT_HOME:
		return

	var player = body as Player
	if player == null:
		return

	if current_state == GhostState.RUN_AWAY:
		get_eaten()
		return

	if current_state == GhostState.CHASE or current_state == GhostState.SCATTER:
		var prejsnje_stanje = current_state
		
		player.die()        
		ustavi_duha_na_mestu()
		
		await get_tree().create_timer(2.0).timeout
		
		prebudi_duha_nazaj(prejsnje_stanje)

func ustavi_duha_na_mestu():
	is_paused_after_killing = true 
	navigation_agent_2d.set_velocity(Vector2.ZERO)
	
	backup_timer.stop()
	scatter_timer.stop()
	run_away_timer.stop()
	if update_chasing_target_position_timer != null:
		update_chasing_target_position_timer.stop()
		
	if body_sprite and body_sprite.animation_player:
		body_sprite.animation_player.stop()

func prebudi_duha_nazaj(staro_stanje: GhostState):
	if game_over:
		return
		
	is_paused_after_killing = false 
	
	current_state = staro_stanje
	if body_sprite and body_sprite.animation_player:
		body_sprite.animation_player.play("moving")
		
	if current_state == GhostState.CHASE:
		start_chasing_pacman()
	else:
		start_scatter_loop()
