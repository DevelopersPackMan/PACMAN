extends Node

var chosen_pellet_color : Color = Color.from_hsv(0.66, 1.0, 1.0) * 3.5 
var used_colors : Array[Color] = [Color.from_hsv(0.66, 1.0, 1.0) * 3.5] 

var max_colors : int = 6
var current_level: int = 1

func is_color_used(barva: Color) -> bool:
	for u_color in used_colors:
		if u_color.is_equal_approx(barva):
			return true
	return false
	
func get_current_color() -> Color:
	return chosen_pellet_color

func next_level():
	current_level += 1
	get_tree().reload_current_scene()
