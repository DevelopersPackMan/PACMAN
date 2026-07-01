extends CanvasLayer

# Povezave do zaslonov
@onready var settings_screen = $SettingsScreen
@onready var win_screen = $WinScreen
@onready var lose_screen = $LoseScreen
@export var animacija_zaslon : Node

@onready var color_panel = $WinScreen/MarginContainer/CenterContainer/Panel 

func _ready():
	hide_everything()

func hide_everything():
	hide() 
	settings_screen.hide()
	win_screen.hide()
	lose_screen.hide()

func game_won():
	hide_everything()
	self.show()
	win_screen.show()
	
	var player = get_parent().get_node_or_null("player")
	var pellets = get_parent().get_node_or_null("Pellets")
	
	var stats_node = win_screen.find_child("StatsLabel")
	if stats_node and player and pellets:
		stats_node.text = "Življenja: " + str(player.lifes) + "    |    Pikice: " + str(pellets.pellets_eaten)			
	
	osvezi_in_povezi_barve()
	
	if Global.used_colors.size() >= Global.max_colors:
		predvajaj_koncno_animacijo()

func game_over():
	hide_everything()
	self.show()
	lose_screen.show()
	
	var pellets = get_parent().get_node_or_null("Pellets")
	if pellets:
		var stats = lose_screen.find_child("StatsLabel") 
		if stats:
			stats.text = "Pikice: " + str(pellets.pellets_eaten)

func osvezi_in_povezi_barve():
	_povezi_texture_rect("BtnRdeca", Color.from_hsv(0.0, 1.0, 1.0) * 3.5)
	_povezi_texture_rect("BtnOranzna", Color.from_hsv(0.08, 1.0, 1.0) * 3.5)
	_povezi_texture_rect("BtnRumena", Color.from_hsv(0.16, 1.0, 1.0) * 3.5) 
	_povezi_texture_rect("BtnZelena", Color.from_hsv(0.33, 1.0, 1.0) * 3.5)
	_povezi_texture_rect("BtnModra", Color.from_hsv(0.66, 1.0, 1.0) * 3.5)
	_povezi_texture_rect("BtnVijolicna", Color.from_hsv(0.83, 1.0, 1.0) * 3.5)

func _povezi_texture_rect(ime_gumba: String, barva: Color) -> void:
	var gumb = color_panel.get_node_or_null(ime_gumba) as TextureRect
	
	if gumb:
		var nov_material = CanvasItemMaterial.new()
		nov_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		gumb.material = nov_material
		
		if Global.is_color_used(barva):
			gumb.modulate = Color(0.3, 0.3, 0.3)
			gumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			gumb.modulate = barva
			gumb.mouse_filter = Control.MOUSE_FILTER_STOP
			
			for k in gumb.gui_input.get_connections():
				gumb.gui_input.disconnect(k.callable)
				
			gumb.gui_input.connect(func(event: InputEvent):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					_on_color_button_pressed(barva)
			)
	else:
		print("NAPAKA: Ne najdem gumba: ", ime_gumba)

func _on_color_button_pressed(izbrana_barva: Color) -> void:
	Global.chosen_pellet_color = izbrana_barva
	Global.used_colors.append(izbrana_barva) # Dodamo med uporabljene
	
	get_tree().paused = false
	hide_everything()
	Global.next_level()

func predvajaj_koncno_animacijo():
	var stats_node = win_screen.find_child("StatsLabel")
	if stats_node:
		stats_node.text = "IGRA KONČANA! Čestitamo za zmago!"
		
	print("Vse barve uspešno odigrane. Čakam 3 sekunde...")
	await get_tree().create_timer(3.0).timeout
	
	print("3 sekunde so potekle! Nalagam sceno iz datoteke...")
	win_screen.hide() 
	
	var animacija_resurs = load("res://scene/rainbow_win.tscn")
	
	if animacija_resurs:
		var nova_animacija = animacija_resurs.instantiate()
		add_child(nova_animacija)
		
		if nova_animacija.has_method("začni_animacijo"):
			nova_animacija.začni_animacijo()
			print("Animacija uspešno zagnana!")
		else:
			print("NAPAKA: Vozlišče je naloženo, ampak skripta nima funkcije 'začni_animacijo'")
	else:
		print("NAPAKA: Datoteke na tej poti sploh ni mogoče najti!")
						
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		if Input.is_key_pressed(KEY_CTRL):
			game_won()
			return

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
	get_tree().paused = false 

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_manu.tscn")
