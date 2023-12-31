class_name Block
extends Node2D


@export var special_offset := false

var valid: bool
var up: bool

var _rotation_counter := 0
var _tile_offsets: Array[Vector2i]
var _rotated_offsets: Array[Vector2i]
var _mouse_coord: Vector2i

var _block_tiles := []

var _area: Area2D

func _ready():
	_area = get_node("Area2D")
	
	for child in get_children():
		if child.is_in_group(Globals.GROUP_BLOCK_TILE):
			_block_tiles.append(child)
			_tile_offsets.append(child.tile_offset)

func setup(p_up: bool, p_rotation_counter := -1):
	change_up(p_up)
	
	_rotated_offsets = _tile_offsets.duplicate()
	
	if !special_offset:
		if p_rotation_counter >= 0:
			_rotation_counter = p_rotation_counter
		else:
			_rotation_counter = randi() % 4
		_update_rotation()

func turn_left():
	if !special_offset:
		_rotation_counter -= 1
		_update_rotation()


func turn_right():
	if !special_offset:
		_rotation_counter += 1
		_update_rotation()


func change_up(p_up: bool):
	up = p_up
	
	for block_tile in _block_tiles:
		block_tile.setup(up)

func _update_rotation():
	_rotation_counter = posmod(_rotation_counter, 4)
	rotation = _rotation_counter * PI / 2.0
	
	for i in _tile_offsets.size():
		var p := _tile_offsets[i]
		
		match _rotation_counter:
			1:
				p = Vector2i(-p.y, p.x)
			2:  
				p = Vector2i(-p.x, -p.y)
			3:
				p = Vector2i(p.y, -p.x)
			_:
				assert(_rotation_counter == 0)
				pass
	
		_rotated_offsets[i] = p
	
	for block_tile in _block_tiles:
		block_tile.fix_arrow_rotation()


func update_mouse_pos(mouse_pos: Vector2):
	if !special_offset:
		_mouse_coord = Tools.to_coord(mouse_pos)
	else:
		_mouse_coord = Vector2i(
			roundi(mouse_pos.x / Globals.TILE_SIZE),
			roundi(mouse_pos.y / Globals.TILE_SIZE))
	
	position = Tools.to_center_pos(_mouse_coord)
	
	valid = true
	
	# Check if pattern is inside the level area
	if State.is_valid_tile(_mouse_coord):
		var is_valid := true
		for offset in _rotated_offsets:
			if !State.is_valid_tile(_mouse_coord + offset) or State.is_tile(_mouse_coord + offset, Enums.TileType.ForcedEmpty):
				valid = false
	else:
		valid = false
	
	# Check if all tiles have the same tile type and can be upped/downed
	if valid:
		var tile_type = State.get_tile(_mouse_coord)
		match tile_type:
			Enums.TileType.Ground:
				for offset in _rotated_offsets:
					if !State.is_tile(_mouse_coord + offset, Enums.TileType.Ground):
						valid = false
			Enums.TileType.Wall:
				if up:
					valid = false
				else:
					for offset in _rotated_offsets:
						if !State.is_tile(_mouse_coord + offset, Enums.TileType.Wall):
							valid = false
			Enums.TileType.Empty:
				if !up:
					valid = false
				else:
					for offset in _rotated_offsets:
						if !State.is_tile(_mouse_coord + offset, Enums.TileType.Empty):
							valid = false
			_:
				printerr("Unknown tiletype")
				valid = false
	
	if valid:
		for body in _area.get_overlapping_bodies():
			if body.is_in_group(Globals.GROUP_PLAYER) or body.is_in_group(Globals.GROUP_FLAG):
				valid = false
	
	if valid:
		modulate = Globals.block_valid_color
	else:
		modulate = Globals.block_invalid_color


func explode():
	for block_tile in _block_tiles:
		block_tile.explode()
		

func apply():
	assert(valid)
	
	var new_tile_type
	if up:
		var tile_type = State.get_tile(_mouse_coord)

		match tile_type:
			Enums.TileType.Ground:
				new_tile_type = Enums.TileType.Wall
			Enums.TileType.Empty:
				new_tile_type = Enums.TileType.Ground
			_:
				printerr("Unexpected tiletype")
				return
	else:
		var tile_type = State.get_tile(_mouse_coord)

		match tile_type:
			Enums.TileType.Wall:
				new_tile_type = Enums.TileType.Ground
			Enums.TileType.Ground:
				new_tile_type = Enums.TileType.Empty
			_:
				printerr("Unexpected tiletype")
				return
	
	Globals.camera.start_shake(Vector2.UP.rotated(randf() * TAU), 1.0, 30.0, 0.15)
	
	for offset in _rotated_offsets:
		State.set_tile(_mouse_coord + offset, new_tile_type)
	
	State.add_tile_score(_rotated_offsets.size())
	
	for body in _area.get_overlapping_bodies():
		if body.is_in_group(Globals.GROUP_MONSTER):
			match body.monster_type:
				Enums.MonsterType.Slime:
					State.add_slime_killed()
				Enums.MonsterType.Dragon:
					State.add_dragon_killed()
				_:
					printerr("Unknown MonsterType")
			body.queue_free()
	
	
