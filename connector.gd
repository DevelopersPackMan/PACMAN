extends Node2D

@onready var desna_area_2d: Area2D = $DesenColorRect/Area2D
@onready var leva_area_2d: Area2D = $LeviColorRect2/Area2D

var allow_left_transition = true
var allow_right_transition = true

func _on_right_area_2d_body_entered(body: Node2D) -> void:
	if body.velocity.x > 0:
		body.position.x = leva_area_2d.global_position.x
		allow_left_transition = false


func _on_right_area_2d_body_exited(body: Node2D) -> void:
	allow_right_transition = true



func _on_left_area_2d_body_entered(body: Node2D) -> void:
	if body.velocity.x < 0:
		body.position.x = desna_area_2d.global_position.x
		allow_right_transition = false



func _on_left_area_2d_body_exited(body: Node2D) -> void:
	allow_right_transition = true
