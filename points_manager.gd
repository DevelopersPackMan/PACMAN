extends Node

class_name PointsManager

var points_for_ghost_eaten = 0
var points = 0

func pause_on_ghost_eaten():
	points += points_for_ghost_eaten
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false
	
