extends HSlider

func _ready():
	# Nastavimo začetno vrednost
	value = GlobalSettings.brightness * 100
	
	# Signal povežemo samo, če še ni povezan (da ne bo napak)
	if not value_changed.is_connected(_on_brightness_changed):
		value_changed.connect(_on_brightness_changed)

func _on_brightness_changed(val):
	var b = val / 100.0
	GlobalSettings.brightness = b
	
	# TA UKAZ SPREMENI BARVO VSEM VOZLIŠČEM V SKUPINI "svetlost" NAENKRAT!
	get_tree().set_group("svetlost", "color", Color(b, b, b, 1.0))
	
	# Za vsak slučaj še izpis v konzolo, da veva, če sploh dela
	print("Svetlost nastavljena na: ", b)
