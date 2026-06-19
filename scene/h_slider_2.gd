extends HSlider

func _ready():
	value = GlobalSettings.volume * 100
	
	value_changed.connect(_on_volume_changed)

func _on_volume_changed(val):
	GlobalSettings.set_volume(val / 100.0)
