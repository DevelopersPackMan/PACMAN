extends Node2D

func _ready():
	# Ob zagonu menuja preberemo vrednost iz GlobalSettings
	apply_brightness()

func apply_brightness():
	var b = GlobalSettings.brightness
	# Namesto $Britness uporabi tole vrstico, ki bo našla vozlišče kjerkoli v tej sceni:
	get_tree().call_group("svetlost", "set_color", Color(b, b, b, 1.0))
	
func _on_start_button_pressed() -> void:
		get_tree().change_scene_to_file("res://main.tscn")



func _on_settings_button_pressed() -> void:
	$CanvasLayer2.show()
	$CanvasLayer2.get_node("MarginContainer/CenterContainer").hide()
	$CanvasLayer2.get_node("gameWon").hide()


func _on_costumaze_button_pressed() -> void:
		get_tree().change_scene_to_file("res://ghost_wardrobe.tscn")



func _on_exit_button_pressed() -> void:
		get_tree().quit()
