extends Node2D

@onready var preview = $CanvasLayer/GhostPreview
@onready var eyes_display = $CanvasLayer/GhostPreview/Eyes
@onready var mouth_display = $CanvasLayer/GhostPreview/Mouth

@onready var btn1 = $CanvasLayer/GhostButton1
@onready var btn2 = $CanvasLayer/GhostButton2
@onready var btn3 = $CanvasLayer/GhostButton3
@onready var btn4 = $CanvasLayer/GhostButton4

var current_mode = "color" # "color", "eyes", "mouth"

# 1. TUKAJ DEFINIRAVA GHOST_BASE (to bo rešilo tvoj error!)
var ghost_base = preload("res://Resources/Graphics/Ghost/Ghost_Body_01.png")

var eye_1 = preload("res://Resources/Graphics/Ghost/angry_face.png")
var eye_2 = preload("res://Resources/Graphics/Ghost/cute_face.png")
var eye_3 = preload("res://Resources/Graphics/Ghost/Moodii.png")
var eye_4 = preload("res://Resources/Graphics/Ghost/sunglasses.png")

var mouth_1 = preload("res://Resources/Graphics/Ghost/ravna_usta.png")
var mouth_2 = preload("res://Resources/Graphics/Ghost/cute_usta.png")
func _ready():
	if GlobalSettings.selected_ghost == 0: GlobalSettings.selected_ghost = 1
	update_button_icons()
	update_preview()

func update_preview():
	# 1. BARVA
	preview.texture = ghost_base
	if GlobalSettings.selected_ghost == 1: preview.self_modulate = Color(0, 0.4, 1) # Modra
	elif GlobalSettings.selected_ghost == 2: preview.self_modulate = Color(1, 1, 0) # Rumena
	elif GlobalSettings.selected_ghost == 3: preview.self_modulate = Color(1, 0, 0) # Rdeča
	elif GlobalSettings.selected_ghost == 4: preview.self_modulate = Color(0, 1, 0) # Zelena
	
	# 2. OČI
	if GlobalSettings.selected_eyes == 1: eyes_display.texture = eye_1
	elif GlobalSettings.selected_eyes == 2: eyes_display.texture = eye_2
	elif GlobalSettings.selected_eyes == 3: eyes_display.texture = eye_3
	elif GlobalSettings.selected_eyes == 4: eyes_display.texture = eye_4
	else: eyes_display.texture = null
	
	# 3. USTA
	if GlobalSettings.selected_mouth == 1: mouth_display.texture = mouth_1
	elif GlobalSettings.selected_mouth == 2: mouth_display.texture = mouth_2
	else: mouth_display.texture = null

# --- GUMBI NA DESNI (Kategorije) ---

func _on_acc_button_1_pressed(): # EYES
	current_mode = "eyes"
	update_button_icons()
	print("Način: OČI")

func _on_acc_button_2_pressed(): # COLOR
	current_mode = "color"
	update_button_icons()
	print("Način: BARVE")

func _on_acc_button_3_pressed(): # MOUTH
	current_mode = "mouth"
	update_button_icons()
	print("Način: USTA")

# --- SPODNJI 4 GUMBI ---

func _on_ghost_button_1_pressed(): _handle_click(1)
func _on_ghost_button_2_pressed(): _handle_click(2)
func _on_ghost_button_3_pressed(): _handle_click(3)
func _on_ghost_button_4_pressed(): _handle_click(4)

func _handle_click(index):
	if current_mode == "color":
		GlobalSettings.selected_ghost = index
	elif current_mode == "eyes":
		if GlobalSettings.selected_eyes == index: GlobalSettings.selected_eyes = 0
		else: GlobalSettings.selected_eyes = index
	elif current_mode == "mouth":
		if GlobalSettings.selected_mouth == index: GlobalSettings.selected_mouth = 0
		else: GlobalSettings.selected_mouth = index
	update_preview()

# --- OSVEŽEVANJE IKON ---

func update_button_icons():
	var white = Color(1, 1, 1)
	
	if current_mode == "color":
		btn1.icon = ghost_base
		btn1.self_modulate = Color(0, 0.4, 1)
		btn2.icon = ghost_base
		btn2.self_modulate = Color(1, 1, 0)
		btn3.icon = ghost_base
		btn3.self_modulate = Color(1, 0, 0)
		btn4.icon = ghost_base
		btn4.self_modulate = Color(0, 1, 0)
		
	elif current_mode == "eyes":
		btn1.icon = eye_1
		btn2.icon = eye_2
		btn3.icon = eye_3
		btn4.icon = eye_4
		btn1.self_modulate = white
		btn2.self_modulate = white
		btn3.self_modulate = white
		btn4.self_modulate = white
		
	elif current_mode == "mouth":
		# Gumbe naredimo čisto bele, da bodo črna usta vidna
		btn1.self_modulate = Color(1, 1, 1)
		btn2.self_modulate = Color(1, 1, 1)
		btn3.self_modulate = Color(1, 1, 1)
		btn4.self_modulate = Color(1, 1, 1)

		btn1.icon = mouth_1
		btn2.icon = mouth_2
		btn3.icon = null
		btn4.icon = null

# ORANŽNI GUMB - Gremo nazaj na glavni meni
func _on_back_button_pressed():
	# Zamenjaj "res://main_manu.tscn" s točno potjo do tvojega začetnega zaslona!
	get_tree().change_scene_to_file("res://main_manu.tscn")

# MODRI GUMB - Potrdimo in gremo nazaj v igro ali meni
func _on_apply_button_pressed():
	print("Nastavitve shranjene!")
	# Tukaj te lahko vrne direktno v igro (main.tscn) ali v meni
	get_tree().change_scene_to_file("res://main_manu.tscn")
