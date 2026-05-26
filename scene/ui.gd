extends CanvasLayer

# Povezave do najinih novih zaslonov
@onready var settings_screen = $SettingsScreen
@onready var win_screen = $WinScreen
@onready var lose_screen = $LoseScreen

func _ready():
	hide_everything()

func hide_everything():
	hide() # Skrije celoten CanvasLayer
	settings_screen.hide()
	win_screen.hide()
	lose_screen.hide()

func game_won():
	hide_everything()
	self.show()
	win_screen.show()
	
	var player = get_parent().get_node("player")
	var pellets = get_parent().get_node("Pellets")
	
	if player and pellets:
		var stats_node = win_screen.find_child("StatsLabel")
		
		if stats_node:
			stats_node.text = "Življenja: " + str(player.lifes) + "    |    Pikice: " + str(pellets.pellets_eaten)			
			
func game_over():
	hide_everything()
	self.show()
	lose_screen.show()
	
	var player = get_parent().get_node("player")
	var pellets = get_parent().get_node("Pellets")
	
	if player and pellets:
		var stats = lose_screen.find_child("StatsLabel") # Pazi, da ima LoseScreen tudi svojo labelo
		if stats:
			stats.text = "Pikice: " + str(pellets.pellets_eaten)
			
func _input(event):
	if event.is_action_pressed("open_settings"):
		if settings_screen.visible:
			hide_everything()
		else:
			show_settings()

func show_settings():
	hide_everything()
	self.show()
	settings_screen.show()

func _on_button_pressed() -> void:
	hide_everything()
	
func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_manu.tscn")
