extends Area2D
class_name Pellet

# POPRAVEK 1: Signal mora sprejeti Boolean (resnično/neresnično), ne 'Pellet'
signal pellet_eaten(is_power_pellet: bool)

@export var should_allow_eating_ghosts = false

func _ready() -> void:
	add_to_group("pikice")
	
	# POPRAVEK 2: Da bo pika svetla in barvna (Unshaded material)
	var nov_material = CanvasItemMaterial.new()
	nov_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	self.material = nov_material
	
	# Pobarvamo piko na izbrano barvo nivoja
	# Uporabi spremenljivko, ki jo imava v Globalni skripti
	if should_allow_eating_ghosts:
		self.modulate = Global.chosen_pellet_color
		
func _on_body_entered(body): 
	# Preverimo, če je v piko vstopil igralec
	if body is Player: 
		# Oddamo signal managerju (pošljemo podatek, če je to velika pika)
		pellet_eaten.emit(should_allow_eating_ghosts)
		
		# Obvestimo še glavno skripto, da je pikica pojedena (za win screen)
		var main_node = get_tree().current_scene
		if main_node and main_node.has_method("_on_pikica_pojedena"):
			main_node._on_pikica_pojedena()
		
		# Izbrišemo piko iz igre
		queue_free()
