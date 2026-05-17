extends Area2D
class_name Palet

signal palet_eaten(palet: Palet)
@export var should_allow_eating_ghosts = false

func _on_body_entered(body): 
	if body is Player: 
		palet_eaten.emit(self)
		queue_free()
		
		if should_allow_eating_ghosts: 
			pass
# TODO: add interactino woth player class to enable eating ghosts
		
