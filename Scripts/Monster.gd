extends CharacterBody2D


@export var speed := 100.0
@export var flying := false


func _physics_process(delta):
	var player_vec := State.player_pos - position
	var move_vec := player_vec.normalized() * speed
	
	velocity = move_vec
	move_and_slide()

	
	if !flying:
		var coord := Tools.to_coord(position)
		if State.is_valid_tile(coord):
			if State.is_tile(coord, Enums.TileType.Empty) or State.is_tile(coord, Enums.TileType.ForcedEmpty):
				queue_free()
