extends Area2D

# Signal, ki javi managerju, da je pikica pojedena
signal pellet_eaten(is_big: bool)

func _ready() -> void:
	# Nastavimo barvo iz Global skripte
	# Če so pikice nevidne, preveri, da Global.chosen_pellet_color ni črn!
	self.modulate = Global.chosen_pellet_color

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body is Player:
		# Oddamo signal (true pomeni, da je to velika pikica)
		pellet_eaten.emit(true)
		queue_free() # Pikica izgine
