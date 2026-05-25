extends Sprite2D
class_name BodySprite

@onready var animation_player = $"../AnimationPlayer"

func _ready() -> void:
	move()
	
func move(): 
	self.modulate = (get_parent() as Ghost).color
	animation_player.play("moving")
	
func run_away(): 
	self.modulate = Color.WHITE
	animation_player.play("run_away")

func start_blinking(): 
	animation_player.play("blinking")
	
