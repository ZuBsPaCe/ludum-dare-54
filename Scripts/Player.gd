extends CharacterBody2D

@export var speed := 200.0


func _ready():
	pass


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
