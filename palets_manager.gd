extends Node

var total_pellets_count = 0
var pellets_eaten = 0

@onready var ui = $"../UI"
@onready var chomp_sound: AudioStreamPlayer2D = $"../Sound/ChompSound"
@export var ghost_array: Array[Ghost]

func _ready():
	var pellets = get_children()
	total_pellets_count = pellets.size()
	for pellet in pellets:
		if pellet.has_signal("pellet_eaten"):
			pellet.pellet_eaten.connect(on_pellet_eaten)

func on_pellet_eaten(should_allow_eating_ghosts: bool):
	pellets_eaten += 1
	if chomp_sound: chomp_sound.play()
	var label = get_parent().get_node_or_null("Panel/lifes")
	if label: label.update_pellets(pellets_eaten)
	
	if should_allow_eating_ghosts: 
		for ghost in ghost_array: 
			if ghost: ghost.trigger_run_away()
	
	if pellets_eaten >= total_pellets_count:
		if ui: ui.game_won()
