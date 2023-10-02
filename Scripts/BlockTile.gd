extends Node2D

@export var tile_offset: Vector2i

@onready var arrow_up := $ArrowUp
@onready var arrow_down := $ArrowDown


func _ready():
	arrow_up.visible = false
	arrow_down.visible = false
#
#	$CPUParticles2D.emitting = false
#	$CPUParticles2D.one_shot = false
#	$CPUParticles2D.explosiveness = 0.8


func setup(up: bool):
	arrow_up.visible = up
	arrow_down.visible = !up

func explode():
	$BlockTile.visible = false
	$ArrowDown.visible = false
	$ArrowUp.visible = false
	$CPUParticles2D.emitting = true


func fix_arrow_rotation():
	arrow_up.global_rotation = 0
	arrow_down.global_rotation = 0
