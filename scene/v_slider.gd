extends VSlider

func _ready():
	value_changed.connect(_on_brightness_changed)

func _on_brightness_changed(val):
	RenderingServer.set_default_clear_color(Color(val/100.0, val/100.0, val/100.0, 1.0))
