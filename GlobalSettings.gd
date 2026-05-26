extends Node
var brightness = 1.0

func set_brightness(val: float):
	brightness = val
	get_tree().current_scene.modulate = Color(val, val, val, 1.0)
