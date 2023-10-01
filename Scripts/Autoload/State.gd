extends Node

var _player_scene: PackedScene
var _slime_scene: PackedScene
var _dragon_scene: PackedScene
var _ghost_scene: PackedScene
var _spawn_scene: PackedScene
var _bullet_scene: PackedScene

var _player: CharacterBody2D

var _runner: Runner
var _game_mode
var _tutorial_level

var _wall_tilemap: TileMap
var _ground_tilemap: TileMap
var _map: Map

var _spawn_group_funcs := []

var _health := 3
var _score := 0

var _empty_cell := Vector2i(0, 4)

var _grass_tops_y = 5
var _grass_tops := [Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5)]

var _grass_fronts_y = 6
var _grass_fronts := [Vector2i(0, 6), Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6)]

var _difficulty

signal health_changed(new_health)
signal score_changed(new_score)


var _debug_single_monster := -1
var _spawn_active := true


var block_disabled := false


var score:float:
	get:
		return _score


var slimes_killed:int
var dragons_killed:int
var ghosts_outlived:int
var duration_secs:float


var player_pos: Vector2:
	get:
		return _player.position


var tutorial_level: int:
	get:
		return _tutorial_level

func setup(
		wall_tilemap: TileMap,
		ground_tilemap: TileMap,
		player_scene: PackedScene,
		slime_scene: PackedScene,
		dragon_scene: PackedScene,
		ghost_scene: PackedScene,
		bullet_scene: PackedScene,
		spawn_scene: PackedScene):
	_wall_tilemap = wall_tilemap
	_ground_tilemap = ground_tilemap
	_player_scene = player_scene
	_slime_scene = slime_scene
	_dragon_scene = dragon_scene
	_ghost_scene = ghost_scene
	_bullet_scene = bullet_scene
	_spawn_scene = spawn_scene


func on_game_start(
		p_runner: Runner,
		p_game_mode,
		p_tutorial_level: int,
		p_map: Map,
		p_player: CharacterBody2D):
	
	_runner = p_runner
	_game_mode = p_game_mode
	_tutorial_level = p_tutorial_level
	_map = p_map
	_player = p_player
	
	_difficulty = Globals.get_setting(Globals.SETTING_DIFFICULTY)
	
	_change_health(3)
	_change_score(0)
	
	slimes_killed = 0
	dragons_killed = 0
	ghosts_outlived = 0
	duration_secs = 0.0
	
	_init_tilemap()
	_init_spawn_groups()
	
	block_disabled = false


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
	_wall_tilemap.clear()
	_ground_tilemap.clear()
	
	for y in _map.height:
		for x in _map.width:
			var coord := Vector2i(x, y)
			_set_cell(coord, _map.get_item(coord))


func _set_cell(coord: Vector2i, tile_type) -> void:
	match tile_type:
		Enums.TileType.Ground:
			_wall_tilemap.set_cells_terrain_connect(0, [coord], 0, -1, false)
			_ground_tilemap.set_cell(0, coord, 0, Tools.rand_item(_grass_tops))
		
		Enums.TileType.Wall:
			_wall_tilemap.set_cells_terrain_connect(0, [coord], 0, 0, false)
			_ground_tilemap.set_cell(0, coord, 0, Tools.rand_item(_grass_tops))
			
		Enums.TileType.Empty, Enums.TileType.ForcedEmpty:
			_wall_tilemap.set_cells_terrain_connect(0, [coord], 0, -1, false)
			_ground_tilemap.set_cell(0, coord, 0, _empty_cell)
			
			if _ground_tilemap.get_cell_atlas_coords(0, coord + Vector2i.UP).y == _grass_tops_y:
				_ground_tilemap.set_cell(0, coord, 0, Tools.rand_item(_grass_fronts))
			
			if _ground_tilemap.get_cell_atlas_coords(0, coord + Vector2i.DOWN).y == _grass_fronts_y:
				_ground_tilemap.set_cell(0, coord + Vector2i.DOWN, 0, _empty_cell)
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
	
	var third_area_width := area_width / 3
	var third_area_height := area_height / 3
	
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
	
	if !_spawn_active:
		return
	
	var monster_types := [
		Enums.MonsterType.Slime,
		Enums.MonsterType.Dragon,
		Enums.MonsterType.Ghost
	]
	
	var monster_type = Tools.rand_item(monster_types)
	
	if _debug_single_monster >= 0:
		monster_type = _debug_single_monster
		_spawn_active = false
	
	for coord in coords:
		add_spawn(_runner, monster_type, coord)
		
		if _debug_single_monster:
			break


func add_spawn(runner: Runner, monster_type, coord: Vector2i):
	var spawn = _spawn_scene.instantiate()
	spawn.setup(runner, monster_type, coord, 3.0)
	spawn.position = Tools.to_center_pos(coord)
	Globals.entity_container.add_child(spawn)



func add_monster(coord: Vector2i, monster_type):
	if !is_tile(coord, Enums.TileType.Ground):
		return
	
	var monster
	match monster_type:
		Enums.MonsterType.Slime:
			monster = _slime_scene.instantiate()
		Enums.MonsterType.Dragon:
			monster = _dragon_scene.instantiate()
		Enums.MonsterType.Ghost:
			monster = _ghost_scene.instantiate()
		_:
			printerr("Unknown Monstertype")
			return
	
	monster.position = Tools.to_center_pos(coord)
	Globals.entity_container.add_child(monster)

func add_bullet(pos: Vector2, dir: Vector2):
	var bullet := _bullet_scene.instantiate()
	bullet.position = pos
	Globals.entity_container.add_child(bullet)
	bullet.setup(dir)


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


func add_tile_score(tile_count: int) -> void:
	_change_score(_score + tile_count * Globals.TILE_SCORE)

func add_slime_killed() -> void:
	slimes_killed += 1
	_change_score(_score + Globals.SLIME_KILLED_SCORE)

func add_dragon_killed() -> void:
	dragons_killed += 1
	_change_score(_score + Globals.DRAGON_KILLED_SCORE)

func add_ghost_outlived() -> void:
	ghosts_outlived += 1
	_change_score(_score + Globals.GHOST_OUTLIVED_SCORE)


func _change_score(new_score):
	_score = new_score
	emit_signal("score_changed", _score)


func increase_difficulty() -> void:
	var current = Globals.get_setting(Globals.SETTING_DIFFICULTY)
	match current:
		Enums.Difficulty.Easy:
			_difficulty = Enums.Difficulty.Normal
			Globals.set_setting(Globals.SETTING_DIFFICULTY, _difficulty)
			Globals.save_settings()
		Enums.Difficulty.Normal:
			_difficulty = Enums.Difficulty.Hard
			Globals.set_setting(Globals.SETTING_DIFFICULTY, _difficulty)
			Globals.save_settings()
		_:
			assert(current == Enums.Difficulty.Hard)


func decrease_difficulty() -> void:
	var current = Globals.get_setting(Globals.SETTING_DIFFICULTY)
	match current:
		Enums.Difficulty.Hard:
			_difficulty = Enums.Difficulty.Normal
			Globals.set_setting(Globals.SETTING_DIFFICULTY, _difficulty)
			Globals.save_settings()
		Enums.Difficulty.Normal:
			_difficulty = Enums.Difficulty.Easy
			Globals.set_setting(Globals.SETTING_DIFFICULTY, _difficulty)
			Globals.save_settings()
		_:
			assert(current == Enums.Difficulty.Easy)


func get_difficulty_name(difficulty) -> String:
	match difficulty:
		Enums.Difficulty.Easy:
			return "Easy"
		Enums.Difficulty.Normal:
			return "Balanced"
		Enums.Difficulty.Hard:
			return "Nightmare"
		_:
			printerr("Unknown Difficulty")
			return "Unknown"
