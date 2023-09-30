class_name Block
extends Node2D


@export var tile_offsets: Array[Vector2i]

@export var special_offset := false

var valid: bool

var _rotation_counter := 0
var _rotated_offsets: Array[Vector2i]
var _mouse_coord: Vector2i

func _ready():
	_rotated_offsets = tile_offsets.duplicate()
	
	if !special_offset:
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


func _update_rotation():
	_rotation_counter = posmod(_rotation_counter, 4)
	rotation = _rotation_counter * PI / 2.0
	
	for i in tile_offsets.size():
		var p := tile_offsets[i]
		
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


func update_mouse_pos(mouse_pos: Vector2):
	if !special_offset:
		_mouse_coord = Tools.to_coord(mouse_pos)
	else:
		_mouse_coord = Vector2i(
			roundi(mouse_pos.x / Globals.TILE_SIZE),
			roundi(mouse_pos.y / Globals.TILE_SIZE))
	
	position = Tools.to_center_pos(_mouse_coord)
	
	valid = true
	
	if State.is_valid_tile(_mouse_coord):
		var is_valid := true
		for offset in _rotated_offsets:
			if !State.is_valid_tile(_mouse_coord + offset):
				valid = false
			elif !State.is_tile(_mouse_coord + offset, Enums.TileType.Ground):
				valid = false
				break
	else:
		valid = false
	
	if valid:
		modulate = Globals.block_valid_color
	else:
		modulate = Globals.block_invalid_color


func apply():
	for offset in _rotated_offsets:
		State.set_tile(_mouse_coord + offset, Enums.TileType.Wall)
