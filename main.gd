extends Node

func _ready():
	pass

func _unhandled_input(event):
	if event.is_action_pressed("open_settings"):
		print("P!")
		$UI.visible = true
