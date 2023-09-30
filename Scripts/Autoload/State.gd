extends Node

var _player_scene: PackedScene
var _monster_scene: PackedScene
var _spawn_scene: PackedScene

var _player: CharacterBody2D

var _runner: Runner
var _tilemap: TileMap
var _map: Map

var _spawn_groups := []

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
		_:
			printerr("Unknown TileType")


func _init_spawn_groups():
	_spawn_groups.clear()
	
	var center_coord := Vector2i(_map.width, _map.height) / 2
	var half_map_width := _map.width / 2
	var half_map_height := _map.height / 2
	var quarter_map_width := _map.width / 4
	var quarter_map_height := _map.height / 4
	
	if true:
		var coords: Array[Vector2i]
		coords.append(center_coord + Vector2i(quarter_map_width, quarter_map_height))
		coords.append(center_coord + Vector2i(quarter_map_width, -quarter_map_height))
		coords.append(center_coord + Vector2i(-quarter_map_width, quarter_map_height))
		coords.append(center_coord + Vector2i(-quarter_map_width, -quarter_map_height))
		_spawn_groups.append(coords)
	
	if true:
		var coords: Array[Vector2i]
		var x := 2
		
		while x < half_map_width:
			coords.append(Vector2i(half_map_width + x, quarter_map_height))
			coords.append(Vector2i(half_map_width - x, quarter_map_height))
			x += 4
		
		_spawn_groups.append(coords)


func add_spawn_group() -> void:
	var coords: Array[Vector2i] = Tools.rand_item(_spawn_groups)
	
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
