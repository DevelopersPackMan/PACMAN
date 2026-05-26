extends Node

func _ready():
	call_deferred("connect_signals")

func connect_signals():
	$player.player_died.connect(_on_player_died)
	
func _on_player_died(lives):
	print("Player umrl! Lives: ", lives)
	$Panel/lifes.update_hearts(lives)
	
func _unhandled_input(event):
	if event.is_action_pressed("open_settings"):
		print("P!")
		$UI.visible = true
