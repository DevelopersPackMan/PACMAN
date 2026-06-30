extends CanvasLayer

@onready var heart1 = $Heart1
@onready var heart2 = $Heart2
@onready var heart3 = $Heart3
@onready var pellet_label = $PelletLabel
@onready var name_label = $HudNameLabel

func update_pellets(count: int):
	pellet_label.text = "PIKICE: " + str(count)

var full_heart = preload("res://Resources/Graphics/lifes/zivljenje.png")
var empty_heart = preload("res://Resources/Graphics/lifes/konec_zivljenja.png")

func _ready():
	update_hearts(3)
	pellet_label.text = "PIKICE: 0"
	if name_label != null:
		name_label.text = GlobalSettings.pacman_name

	
func update_hearts(lives: int):
	heart1.texture = full_heart if lives >= 1 else empty_heart
	heart2.texture = full_heart if lives >= 2 else empty_heart
	heart3.texture = full_heart if lives >= 3 else empty_heart
