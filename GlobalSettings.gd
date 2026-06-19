extends Node
var brightness = 1.0
var volume = 1.0 

func set_volume(val_linear: float):
	volume = val_linear
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(val_linear))

func set_brightness(val: float):
	brightness = val
	get_tree().current_scene.modulate = Color(val, val, val, 1.0)
