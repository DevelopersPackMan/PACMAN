extends Node2D

@onready var preview = $CanvasLayer/GhostPreview
@onready var pattern_display = $CanvasLayer/GhostPreview/Pattern
@onready var name_input = $CanvasLayer/NameInput

@onready var btn1 = $CanvasLayer/GhostButton1
@onready var btn2 = $CanvasLayer/GhostButton2
@onready var btn3 = $CanvasLayer/GhostButton3
@onready var btn4 = $CanvasLayer/GhostButton4
@onready var prev_page_btn = $CanvasLayer/PrevPageButton
@onready var next_page_btn = $CanvasLayer/NextPageButton

const COLORS_PER_PAGE = 4

var current_mode = "color" # "color", "pattern"
var color_page = 0 # 0..3 (4 strani po 4 barve, zadnja stran ima 3)

# OSNOVNA SLIKA PACMANA (enaka slika kot v scene/pacman.tscn -> Sprite2D)
var ghost_base = preload("res://Resources/Graphics/Pacman_01.png")

# VZORCI - 4 izbire
var pattern_1 = preload("res://Resources/Graphics/Patterns/pike.png")
var pattern_2 = preload("res://Resources/Graphics/Patterns/proge.png")
var pattern_3 = preload("res://Resources/Graphics/Patterns/srca.png")
var pattern_4 = preload("res://Resources/Graphics/Patterns/zvezdice.png")

# 15 BARV (4 strani po 4, zadnja s 3) - indeks 1-15, ujema se z GlobalSettings.selected_ghost
var colors = [
	Color(1.00, 1.00, 0),  # 1  Rumena
	Color(1.00, 0.78, 0),  # 2  Zlata
	Color(1.00, 0.55, 0),  # 3  Oranžna
	Color(1.00, 0.32, 0),  # 4  Temna oranžna
	Color(1.00, 0.08, 0),  # 5  Rdeča
	Color(0.60, 0.0, 0),   # 6  Temno rdeča
	Color(0.55, 0.50, 0),  # 7  Olivna
	Color(0.62, 1.00, 0),  # 8  Limeta
	Color(0.32, 1.00, 0),  # 9  Travnata zelena
	Color(0.08, 1.00, 0),  # 10 Zelena
	Color(0.0, 0.45, 0),   # 11 Temno zelena
	Color(0.40, 0.35, 0),  # 12 Kaki
	Color(0.85, 0.95, 0),  # 13 Peščena
	Color(0.95, 0.60, 0),  # 14 Bledo zlata
	Color(0.15, 0.20, 0),  # 15 Mahovita
]

func _ready():
	if GlobalSettings.selected_ghost == 0: GlobalSettings.selected_ghost = 1
	# Postavimo se na stran, kjer je trenutno izbrana barva
	color_page = int((GlobalSettings.selected_ghost - 1) / COLORS_PER_PAGE)
	update_button_icons()
	update_preview()
	
	if name_input:
		name_input.text = GlobalSettings.pacman_name
		name_input.text_changed.connect(_on_name_changed)

func get_color(index: int) -> Color:
	if index >= 1 and index <= colors.size():
		return colors[index - 1]
	return Color(1, 1, 0)

func get_max_page() -> int:
	return int((colors.size() - 1) / COLORS_PER_PAGE)

func update_preview():
	# 1. BARVA
	preview.texture = ghost_base
	preview.self_modulate = get_color(GlobalSettings.selected_ghost)
	
	# 2. VZOREC (pattern)
	match GlobalSettings.selected_pattern:
		1: pattern_display.texture = pattern_1
		2: pattern_display.texture = pattern_2
		3: pattern_display.texture = pattern_3
		4: pattern_display.texture = pattern_4
		_: pattern_display.texture = null

# --- GUMBI NA DESNI (Kategorije) ---

func _on_acc_button_2_pressed(): # COLOR
	current_mode = "color"
	update_button_icons()
	print("Način: BARVE (Pacman)")

func _on_acc_button_1_pressed(): # PATTERN
	current_mode = "pattern"
	update_button_icons()
	print("Način: VZORCI (Pacman)")

# --- SPODNJIH 4 GUMBOV ---

func _on_ghost_button_1_pressed(): _handle_click(0)
func _on_ghost_button_2_pressed(): _handle_click(1)
func _on_ghost_button_3_pressed(): _handle_click(2)
func _on_ghost_button_4_pressed(): _handle_click(3)

func _handle_click(slot_index):
	if current_mode == "color":
		var color_index = color_page * COLORS_PER_PAGE + slot_index + 1
		if color_index <= colors.size():
			GlobalSettings.selected_ghost = color_index
	elif current_mode == "pattern":
		var index = slot_index + 1
		if index > 4: return
		if GlobalSettings.selected_pattern == index: GlobalSettings.selected_pattern = 0
		else: GlobalSettings.selected_pattern = index
	update_preview()
	update_button_icons()

# --- LISTANJE STRANI (samo za barve) ---

func _on_prev_page_button_pressed():
	if current_mode != "color": return
	if color_page <= 0: return
	color_page -= 1
	update_button_icons()

func _on_next_page_button_pressed():
	if current_mode != "color": return
	if color_page >= get_max_page(): return
	color_page += 1
	update_button_icons()

func _on_name_changed(new_text):
	GlobalSettings.pacman_name = new_text

# --- OSVEŽEVANJE IKON ---

func update_button_icons():
	var white = Color(1, 1, 1)
	var buttons = [btn1, btn2, btn3, btn4]
	
	if current_mode == "color":
		# Puščici sta klikljivi v barvnem načinu, ampak onemogočeni na robovih (prva/zadnja stran)
		prev_page_btn.disabled = (color_page <= 0)
		next_page_btn.disabled = (color_page >= get_max_page())
		prev_page_btn.modulate = Color(1,1,1,1) if not prev_page_btn.disabled else Color(0.4,0.4,0.4,1)
		next_page_btn.modulate = Color(1,1,1,1) if not next_page_btn.disabled else Color(0.4,0.4,0.4,1)
		
		for i in range(COLORS_PER_PAGE):
			var color_index = color_page * COLORS_PER_PAGE + i + 1
			var b = buttons[i]
			if color_index <= colors.size():
				b.visible = true
				b.icon = ghost_base
				b.self_modulate = colors[color_index - 1]
			else:
				b.visible = false
		
	elif current_mode == "pattern":
		# Puščici sta v vzorčnem načinu onemogočeni (sive), ker listanje ni na voljo
		prev_page_btn.disabled = true
		next_page_btn.disabled = true
		prev_page_btn.modulate = Color(0.4,0.4,0.4,1)
		next_page_btn.modulate = Color(0.4,0.4,0.4,1)
		
		btn1.visible = true
		btn2.visible = true
		btn3.visible = true
		btn4.visible = true
		btn1.icon = pattern_1
		btn2.icon = pattern_2
		btn3.icon = pattern_3
		btn4.icon = pattern_4
		btn1.self_modulate = white
		btn2.self_modulate = white
		btn3.self_modulate = white
		btn4.self_modulate = white

# ORANŽNI GUMB - Gremo nazaj na glavni meni
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://main_manu.tscn")

# MODRI GUMB - Potrdimo in gremo nazaj v igro ali meni
func _on_apply_button_pressed():
	print("Nastavitve shranjene!")
	get_tree().change_scene_to_file("res://main.tscn")
