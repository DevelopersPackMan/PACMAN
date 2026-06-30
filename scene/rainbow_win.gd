extends Control

@onready var rainbow_rect = $RainbowRect
@onready var congrats_label = $CongratsLabel

const FRAME_WIDTH = 300
const FRAME_HEIGHT = 192
const COLUMNS = 9
const ROWS = 14
const TOTAL_FRAMES = 125
const FPS = 30.0

var frame_textures: Array = []
var current_frame = 0
var elapsed = 0.0
var finished = false

func _ready():
	var sheet = preload("res://Resources/Graphics/Rainbow/mavrica_sheet.png")
	
	var count = 0
	for row in range(ROWS):
		for col in range(COLUMNS):
			if count >= TOTAL_FRAMES:
				break
			var atlas = AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(col * FRAME_WIDTH, row * FRAME_HEIGHT, FRAME_WIDTH, FRAME_HEIGHT)
			frame_textures.append(atlas)
			count += 1
	
	if rainbow_rect != null and frame_textures.size() > 0:
		rainbow_rect.texture = frame_textures[0]
	
	if congrats_label != null:
		var ime = GlobalSettings.pacman_name
		if ime == "":
			congrats_label.text = "ČESTITKE!\nOSVOJIL/A SI VSE BARVE!"
		else:
			congrats_label.text = "ČESTITKE, " + ime.to_upper() + "!\nOSVOJIL/A SI VSE BARVE!"
		congrats_label.modulate.a = 0.0 # na začetku nevidno

func _process(delta):
	if frame_textures.size() == 0:
		return
	if finished:
		# Postopoma prikažemo besedilo (fade in) ko je animacija koncana
		if congrats_label != null and congrats_label.modulate.a < 1.0:
			congrats_label.modulate.a = min(congrats_label.modulate.a + delta * 2.0, 1.0)
		return
	elapsed += delta
	var target_frame = int(elapsed * FPS)
	if target_frame >= frame_textures.size():
		current_frame = frame_textures.size() - 1
		finished = true
	else:
		current_frame = target_frame
	if rainbow_rect != null:
		rainbow_rect.texture = frame_textures[current_frame]
