extends Node

var preostale_pikice: int = 0

func _ready():
	get_tree().paused = false
	
	call_deferred("connect_signals")

	if has_node("TileMap"):
		$TileMap.modulate = Global.chosen_pellet_color

	if has_node("CanvasLayer/TextureRect"):
		$CanvasLayer/TextureRect.modulate = Global.chosen_pellet_color.darkened(0.7)

	apply_brightness()

	preostale_pikice = get_tree().get_nodes_in_group("pikice").size()
	print("Nivo naložen. Število pikic na polju: ", preostale_pikice)


func apply_brightness():
	if has_node("CanvasModulate"):
		var b = GlobalSettings.brightness
		$CanvasModulate.color = Color(b, b, b, 1.0)


func connect_signals():
	if has_node("player"):
		$player.player_died.connect(_on_player_died)


func _on_player_died(lives):
	if has_node("Panel/lifes"):
		$Panel/lifes.update_hearts(lives)

	if lives <= 0:
		# dodana pavza
		get_tree().paused = true
		if has_node("UI"):
			$UI.game_over()


func _on_pikica_pojedena():
	preostale_pikice -= 1

	if preostale_pikice <= 0:
		# dodana pavza
		get_tree().paused = true
		if has_node("UI/WinScreen"):
			$UI/WinScreen.show()
		elif has_node("UI"):
			$UI.game_won()


func _unhandled_input(event):
	if event.is_action_pressed("open_settings"):
		if has_node("UI"):
			$UI.show_settings()


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		get_tree().paused = true
		if has_node("UI"): $UI.game_won()
		if has_node("UI/WinScreen"): $UI/WinScreen.show()

	if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		get_tree().paused = true
		if has_node("UI"): $UI.game_over()
