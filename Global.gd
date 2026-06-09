extends Node

var current_level: int = 1

var chosen_pellet_color: Color = Color.MEDIUM_PURPLE 

func get_current_color() -> Color:
	return chosen_pellet_color

func next_level():
	current_level += 1
	get_tree().reload_current_scene()
