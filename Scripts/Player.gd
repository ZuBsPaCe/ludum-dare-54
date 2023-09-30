extends CharacterBody2D

@export var speed := 200.0

@onready var _hit_area := $HitArea

var _hit_cooldown := Cooldown.new()
var _dead := false

func _ready():
	_hit_cooldown.setup(self, 2, true)


func _physics_process(delta):	
	var move_vec := Vector2()
	
	if Input.is_action_pressed("up"):
		move_vec += Vector2.UP
		
	if Input.is_action_pressed("down"):
		move_vec += Vector2.DOWN
		
	if Input.is_action_pressed("right"):
		move_vec += Vector2.RIGHT
	
	if Input.is_action_pressed("left"):
		move_vec += Vector2.LEFT
	
	move_vec = move_vec.normalized() * speed
	
#	var direction = Input.get_axis("ui_left", "ui_right")
#	if direction:
#		velocity.x = direction * SPEED
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	velocity = move_vec
	move_and_slide()
	
	if _hit_cooldown.done:
		if _hit_area.has_overlapping_bodies():
			if State.decrease_health() > 0:
				_hit_cooldown.restart()
			else:
				_die()
	
	var coord := Tools.to_coord(position)
	if State.is_valid_tile(coord):
		if State.is_tile(coord, Enums.TileType.Empty) or State.is_tile(coord, Enums.TileType.ForcedEmpty):
			_die()

func _die():
	if _dead:
		return
	_dead = true
	set_physics_process(false)
	Globals.switch_game_state(Enums.GameState.DEAD)
