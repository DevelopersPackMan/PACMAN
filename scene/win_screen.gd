extends Control

func _ready() -> void:
	hide()

	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnRdeca", Color.from_hsv(0.0, 1.0, 1.0))
	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnOranzna", Color.from_hsv(0.08, 1.0, 1.0))
	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnRumnena", Color.from_hsv(0.16, 1.0, 1.0)) 
	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnZelena", Color.from_hsv(0.33, 1.0, 1.0))
	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnModra", Color.from_hsv(0.66, 1.0, 1.0))
	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnVijolicna", Color.from_hsv(0.83, 1.0, 1.0))

func _povezi_texture_rect(pot_do_vozelisca: String, barva: Color) -> void:
	if has_node(pot_do_vozelisca):
		var vozlisce = get_node(pot_do_vozelisca) as TextureRect
		
		vozlisce.mouse_filter = Control.MOUSE_FILTER_STOP
		
		vozlisce.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_button_pressed(barva)
		)
	else:
		print("NAPAKA: Ne najdem gumba na poti: ", pot_do_vozelisca)

func _on_button_pressed(izbrana_barva: Color) -> void:
	var svetlejša_barva = izbrana_barva * 1.5 
	
	print("Izbrana barva (ojačana):", svetlejša_barva)
	Global.chosen_pellet_color = svetlejša_barva

	hide()
	Global.next_level()
