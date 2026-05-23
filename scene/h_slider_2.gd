extends HSlider

func _ready():
	value = 100
	value_changed.connect(_on_volume_changed)

func _on_volume_changed(val):
	AudioServer.set_bus_volume_db(0, linear_to_db(val / 100.0))
