extends CharacterBody2D

@export var speed := 100.0


var _dir:= Vector2.ZERO
var _viewport_rect: Rect2


func setup(dir: Vector2) -> void:
	_dir = dir
	_viewport_rect = get_viewport_rect()


func _physics_process(delta):
	if _dir == Vector2.ZERO:
		return
	
	var collision := move_and_collide(_dir * speed * delta)
	if collision:
		# Only handle tilemap collision here. Player checks for bullet collision
		queue_free()
	elif position.x < -32 or position.y < -32 or position.x > _viewport_rect.size.x + 32 or position.y > _viewport_rect.size.y + 32:
		queue_free()
