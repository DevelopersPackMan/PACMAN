extends Control

func _ready() -> void:
	hide()

	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnRdeca", Color.from_hsv(0.0, 1.0, 1.0) * 3.5)
	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnOranzna", Color.from_hsv(0.08, 1.0, 1.0) * 3.5)
	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnRumena", Color.from_hsv(0.16, 1.0, 1.0) * 3.5) 
	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnZelena", Color.from_hsv(0.33, 1.0, 1.0) * 3.5)
	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnModra", Color.from_hsv(0.66, 1.0, 1.0) * 3.5)
	_povezi_texture_rect("MarginContainer/CenterContainer/Panel/BtnVijolicna", Color.from_hsv(0.83, 1.0, 1.0) * 3.5)

func _povezi_texture_rect(pot_do_vozelisca: String, barva: Color) -> void:
	if has_node(pot_do_vozelisca):
		var vozlisce = get_node(pot_do_vozelisca) as TextureRect
		
		# Material za polno barvo (brez senc)
		var nov_material = CanvasItemMaterial.new()
		nov_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		vozlisce.material = nov_material
		
		vozlisce.modulate = barva
		vozlisce.mouse_filter = Control.MOUSE_FILTER_STOP
		
		vozlisce.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_button_pressed(barva)
		)
	else:
		print("NAPAKA: Ne najdem gumba na poti: ", pot_do_vozelisca)

func _on_button_pressed(izbrana_barva: Color) -> void:
	Global.chosen_pellet_color = izbrana_barva
	
	get_tree().paused = false
	
	hide()
	Global.next_level()
