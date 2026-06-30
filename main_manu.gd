extends Node2D

func _ready():
	pass

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func _on_settings_button_pressed() -> void:
	$CanvasLayer2.show_settings()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_costumaze_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ghost_wardrobe.tscn")
