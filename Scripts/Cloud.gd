extends Sprite2D


@export var speed := 50.0
@export var width := 512.0

func _ready():
	frame = randi() % 4


func _process(delta):
	position += Vector2.RIGHT * speed * delta
	
	if position.x > get_viewport_rect().size.x + width:
		queue_free()
