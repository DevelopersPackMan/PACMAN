extends Node

func _ready():
	call_deferred("connect_signals")
	# Dodaj tole vrstico:
	apply_brightness()

func apply_brightness():
	# Preverimo, če imamo CanvasModulate v tej sceni
	if has_node("CanvasModulate"):
		var b = GlobalSettings.brightness
		$CanvasModulate.color = Color(b, b, b, 1.0)
		
func connect_signals():
	$player.player_died.connect(_on_player_died)
	
func _on_player_died(lives):
	print("Player umrl! Lives: ", lives)
	$Panel/lifes.update_hearts(lives)
	
func _unhandled_input(event):
	if event.is_action_pressed("open_settings"):
		print("P!")
		$UI.visible = true
