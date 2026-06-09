extends Node

var preostale_pikice: int = 0

func _ready():
	call_deferred("connect_signals")

	if has_node("TileMap"):
		$TileMap.modulate = Global.chosen_pellet_color

	apply_brightness()

	preostale_pikice = get_tree().get_nodes_in_group("pikice").size()
	print("Nivo naložen. Število pikic na polju: ", preostale_pikice)


func apply_brightness():
	if has_node("CanvasModulate"):
		var b = GlobalSettings.brightness

		$CanvasModulate.color = Color(b, b, b, 1.0)


func connect_signals():
	$player.player_died.connect(_on_player_died)


func _on_player_died(lives):
	print("Player umrl! Lives: ", lives)
	$Panel/lifes.update_hearts(lives)

	if lives <= 0:
		print("KONEC IGRE: Življenja so pošla!")
		$UI.game_over()


func _on_pikica_pojedena():
	preostale_pikice -= 1

	if preostale_pikice <= 0:
		print("Vse pikice počiščene! Odpiram win screen...")

		if has_node("UI/WinScreen"):
			$UI/WinScreen.show()


func _unhandled_input(event):
	if event.is_action_pressed("open_settings"):
		print("Odpiram nastavitve...")
		$UI.show_settings()


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		print("TEST WIN")
		$UI.game_won()
		await get_tree().create_timer(1.5).timeout

		if has_node("UI/WinScreen"):
			$UI/WinScreen.show()

	if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		print("TEST LOSE")
		$UI.game_over()
