extends Area2D
class_name Pellet

signal pellet_eaten(pallet: Pellet)
@export var should_allow_eating_ghosts = false

func _ready() -> void:
	add_to_group("pikice")
	
	if should_allow_eating_ghosts:
		self.modulate = Global.get_current_color()
		
func _on_body_entered(body): 
	if body is Player: 
		pellet_eaten.emit(should_allow_eating_ghosts)
		
		var main_node = get_tree().current_scene
		if main_node and main_node.has_method("_on_pikica_pojedena"):
			main_node._on_pikica_pojedena()
		
		queue_free()
