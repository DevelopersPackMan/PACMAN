extends Node

var total_pellets_count = 0
var pellets_eaten = 0

@onready var ui = $"../UI"
@export var ghost_array: Array[Ghost]

func _ready():
	var maze = get_parent().get_node_or_null("TileMap")
	if maze:
		maze.modulate = Global.chosen_pellet_color.darkened(0.3)

	var pellets = get_children()
	total_pellets_count = pellets.size()
	
	print("Nivo pripravljen. Najdenih pikic: ", total_pellets_count)

	for pellet in pellets:
		if pellet.has_signal("pellet_eaten"):
			if pellet.pellet_eaten.is_connected(on_pellet_eaten):
				pellet.pellet_eaten.disconnect(on_pellet_eaten)
			pellet.pellet_eaten.connect(on_pellet_eaten)

func on_pellet_eaten(should_allow_eating_ghosts: bool):
	pellets_eaten += 1
	
	# Posodobimo števec v UI
	var label = get_parent().get_node_or_null("Panel/lifes")
	if label:
		label.update_pellets(pellets_eaten)
	
	if should_allow_eating_ghosts: 
		print("Velika pika pojedena! Duhci bežite!")
		
		# --- DODANO: ZVOK ZA POWER PELLET ---
		# Poiščemo igralca v sceni in mu rečemo, naj sproži zvok
		var player = get_parent().get_node_or_null("player")
		if player and player.has_method("eat_power_pellet"):
			player.eat_power_pellet()
		# -------------------------------------

		for ghost in ghost_array: 
			if ghost != null: 
				ghost.trigger_run_away()
	
	# LOGIKA ZA ZMAGO
	if pellets_eaten >= total_pellets_count:
		print("ZMAGA! Vse pikice so pojedene.")
		if ui:
			ui.game_won()
