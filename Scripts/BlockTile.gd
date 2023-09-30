extends Sprite2D

@export var tile_offset: Vector2i

@onready var arrow_up := $ArrowUp
@onready var arrow_down := $ArrowDown


func _ready():
	arrow_up.visible = false
	arrow_down.visible = false


func setup(up: bool):
	arrow_up.visible = up
	arrow_down.visible = !up


func fix_arrow_rotation():
	arrow_up.global_rotation = 0
	arrow_down.global_rotation = 0
