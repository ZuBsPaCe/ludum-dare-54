extends Node

var _player: CharacterBody2D

var _tilemap: TileMap
var _map: Map


var player_pos: Vector2:
	get:
		return _player.position

func setup(tilemap: TileMap):
	_tilemap = tilemap


func on_game_start(
		p_map: Map,
		p_player: CharacterBody2D):
	
	print("State: Game started")
	_map = p_map
	_player = p_player
	
	_init_tilemap()


func on_game_stopped():
	print("State: Game stopped")


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
