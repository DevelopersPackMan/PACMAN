extends CanvasLayer

func _ready():
	# 1. Zaženemo animacijo, ki si jo naredila
	$AnimationPlayer.play("loading")
	
	# 2. Počakamo, da se animacija konča
	await $AnimationPlayer.animation_finished
	
	# 3. Ko je konec, preklopimo na glavno igro
	get_tree().change_scene_to_file("res://main.tscn")
