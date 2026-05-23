extends CanvasLayer
class_name UI

@onready var center_container: CenterContainer = $MarginContainer/CenterContainer

func _ready():
	hide()
	
func game_won():
	print("KLIK: Funkcija game_won() v UI se je uspešno zagnala!")
	self.show() 
	center_container.show()

func _input(event):
	if event.is_action_pressed("open_settings"):
		hide()


func _on_button_pressed() -> void:
	get_parent().get_node("TileMap").modulate = Color(GlobalSettings.brightness, GlobalSettings.brightness, GlobalSettings.brightness, 1.0)
	hide()
