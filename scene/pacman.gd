extends CharacterBody2D

class_name Player

@export var speed = 300
var movement_direction = Vector2.ZERO

func _physics_process(delta):
	get_input()
	velocity = movement_direction * speed
	move_and_slide()
	
	
func get_input():
	if Input.is_action_pressed("ui_left"):  # Dodano ui_
		movement_direction = Vector2.LEFT
		rotation_degrees = 0
	elif Input.is_action_pressed("ui_right"): # Dodano ui_
		movement_direction = Vector2.RIGHT
		rotation_degrees = 180
	elif Input.is_action_pressed("ui_down"): # Dodano ui_
		movement_direction = Vector2.DOWN
		rotation_degrees = 270
	elif Input.is_action_pressed("ui_up"): # Dodano ui_
		movement_direction = Vector2.UP
		rotation_degrees = 90
