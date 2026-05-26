extends Node

func _ready():
	call_deferred("connect_signals")
	apply_brightness()

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
	
func _unhandled_input(event):
	if event.is_action_pressed("open_settings"):
		print("P!")
		$UI.show_settings()
		
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		print("TEST: Prisila zmage!")
		$UI.game_won()
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		print("TEST: Prisila poraza!")
		$UI.game_over()
	
