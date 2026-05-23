extends HSlider

func _ready():
	value = GlobalSettings.brightness * 100
	value_changed.connect(_on_brightness_changed)

func _on_brightness_changed(val):
	GlobalSettings.brightness = val / 100.0
	get_parent().modulate = Color(val/100.0, val/100.0, val/100.0, 1.0)
