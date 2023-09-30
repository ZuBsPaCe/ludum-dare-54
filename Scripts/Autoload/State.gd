extends Node

var _player_scene: PackedScene
var _monster_scene: PackedScene
var _spawn_scene: PackedScene

var _player: CharacterBody2D

var _runner: Runner
var _tilemap: TileMap
var _map: Map

var _spawn_group_funcs := []

var _health := 3


signal health_changed(new_health)


var player_pos: Vector2:
	get:
		return _player.position

func setup(
		tilemap: TileMap,
		player_scene: PackedScene,
		monster_scene: PackedScene,
		spawn_scene: PackedScene):
	_tilemap = tilemap
	_player_scene = player_scene
	_monster_scene = monster_scene
	_spawn_scene = spawn_scene


func on_game_start(
		runner: Runner,
		p_map: Map,
		p_player: CharacterBody2D):
	
	_runner = runner
	_map = p_map
	_player = p_player
	
	_change_health(3)
	
	_init_tilemap()
	_init_spawn_groups()


func on_game_reset():
	for child in Globals.overlay_container.get_children():
		child.queue_free()
	
	for child in Globals.entity_container.get_children():
		child.queue_free()



func is_valid_tile(coord: Vector2i) -> bool:
	return _map.is_valid(coord)

func get_tile(coord: Vector2i) -> int:
	return _map.get_item(coord)


func is_tile(coord: Vector2i, tile_type) -> bool:
	return _map.is_item(coord, tile_type)


func set_tile(coord: Vector2i, tile_type) -> void:
	_map.set_item(coord, tile_type)
	_set_cell(coord, tile_type)


func _init_tilemap():
	for y in _map.height:
		for x in _map.width:
			var coord := Vector2i(x, y)
			_set_cell(coord, _map.get_item(coord))


func _set_cell(coord: Vector2i, tile_type) -> void:
	match tile_type:
		Enums.TileType.Ground:
			_tilemap.set_cell(0, coord, 0, Vector2i(0, 0))
		Enums.TileType.Wall:
			_tilemap.set_cell(0, coord, 0, Vector2i(1, 0))
		Enums.TileType.Empty, Enums.TileType.ForcedEmpty:
			_tilemap.set_cell(0, coord)
		_:
			printerr("Unknown TileType")


func _init_spawn_groups():
	_spawn_group_funcs.clear()
	
#	var center_coord := Vector2i(_map.width, _map.height) / 2
	
	var border := 1
	
#	var map_width = _map.width
#	var map_height = _map.height
#	var half_map_width := _map.width / 2
#	var half_map_height := _map.height / 2
#	var quarter_map_width := _map.width / 4
#	var quarter_map_height := _map.height / 4

	var center_x := _map.width / 2
	var center_y := _map.height / 2
	
	var area_width := _map.width - 2 * border
	var area_height := _map.height - 2 * border
	
	var half_area_width := area_width / 2
	var half_area_height := area_height / 2
	
	var third_area_width := area_width / 2
	var third_area_height := area_height / 2
	
	var min_x := border
	var max_x := _map.width - border - 1
	var min_y := border
	var max_y := _map.height - border - 1
	
	var tl_x := min_x + 1 * (max_x - min_x) / 4
	var tl_y := min_y + 1 *(max_y - min_y) / 4
	
	var tr_x := min_x + 3 * (max_x - min_x) / 4
	var tr_y := min_y + 1 * (max_y - min_y) / 4
	
	var bl_x := min_x + 1 * (max_x - min_x) / 4
	var bl_y := min_y + 3 *(max_y - min_y) / 4
	
	var br_x := min_x + 3 * (max_x - min_x) / 4
	var br_y := min_y + 3 *(max_y - min_y) / 4
	
	
	var lambda
	
	lambda = func():
		# Rect corners
		var coords: Array[Vector2i]
		var offset_x := randi() % third_area_width
		var offset_y := randi() % third_area_height
		
		coords.append(Vector2i(min_x + offset_x, min_y + offset_y))
		coords.append(Vector2i(max_x - offset_x, min_y + offset_y))
		coords.append(Vector2i(min_x + offset_x, max_y - offset_y))
		coords.append(Vector2i(max_x - offset_x, max_y - offset_y))
		return coords
	_spawn_group_funcs.append(lambda)
#
#	lambda = func():
#		var coords: Array[Vector2i]
#		var x := 2
#
#		while x < half_map_width:
#			coords.append(Vector2i(half_map_width + x, quarter_map_height))
#			coords.append(Vector2i(half_map_width - x, quarter_map_height))
#			x += 4
#
#		_spawn_groups.append(coords)
#	_spawn_group_funcs.append(lambda)
#
#
#	lambda = func():
#		var coords: Array[Vector2i]
#		var x := 2
#
#		while x < half_map_width:
#			coords.append(Vector2i(half_map_width + x, 3 * quarter_map_height))
#			coords.append(Vector2i(half_map_width - x, 3 * quarter_map_height))
#			x += 4
#
#		_spawn_groups.append(coords)
#	_spawn_group_funcs.append(lambda)
#
#
#	lambda = func():
#		var coords: Array[Vector2i]
#		var x := randi(, map_wi)
#
#		while x < half_map_width:
#			coords.append(Vector2i(half_map_width + x, 3 * quarter_map_height))
#			coords.append(Vector2i(half_map_width - x, 3 * quarter_map_height))
#			x += 4
#
#		_spawn_groups.append(coords)
#	_spawn_group_funcs.append(lambda)

func add_spawn_group() -> void:
	var coords: Array[Vector2i] = Tools.rand_item(_spawn_group_funcs).call()
	
	for coord in coords:
		_add_spawn(coord)


func _add_spawn(coord: Vector2i):
	var spawn = _spawn_scene.instantiate()
	spawn.setup(_runner, coord, 3.0)
	spawn.position = Tools.to_center_pos(coord)
	Globals.entity_container.add_child(spawn)



func add_monster(coord: Vector2i):
	if !is_tile(coord, Enums.TileType.Ground):
		return
	
	var monster = _monster_scene.instantiate()
	monster.position = Tools.to_center_pos(coord)
	Globals.entity_container.add_child(monster)


func increase_health() -> int:
	_change_health(_health + 1)
	return _health


func decrease_health() -> int:
	_change_health(_health - 1)
	return _health


func _change_health(new_health):
	if new_health < 0:
		new_health = 0
	_health = new_health
	emit_signal("health_changed", _health)
