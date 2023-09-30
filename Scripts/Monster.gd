extends CharacterBody2D


@export var speed := 100.0


func _physics_process(delta):
	var player_vec := State.player.position - position
	var move_vec := player_vec.normalized() * speed
	
	velocity = move_vec
	move_and_slide()


