extends Node2D


const GameState := preload("res://Scripts/Tools/Examples/ExampleGameState.gd").GameState

@export var player_scene: PackedScene
@export var monster_scene: PackedScene

@export var block_scenes: Array[PackedScene]

@onready var _tilemap := $Tilemap

var _map: Map

var _block: Block


var game_running := false
func _ready():
	Effects.setup($Camera2D)



func _process(delta):
	if game_running:
		var mouse_pos := get_global_mouse_position()
		var mouse_coord := Tools.to_coord(mouse_pos)
		
		if Input.is_action_just_pressed("turn_left"):
			_block.turn_left()
		elif Input.is_action_just_pressed("turn_right"):
			_block.turn_right()
		
		_block.update_mouse_pos(mouse_pos)
		
		if _block.valid and Input.is_action_just_pressed("left_click"):
			_block.apply()
			_create_new_block()


# Can yield
func start(runner: Runner):
	game_running = false
	
#	runner.create_tween(self).tween_property($Dummy, "position", Vector2(Tools.get_visible_rect().get_center()), 1.0)
#	if !await runner.proceed:
#		return
#
#	runner.create_timer(self, 1.0)
#	if !await runner.proceed:
#		return
	
	var viewport_size := get_viewport_rect().size

	_map = Map.new(viewport_size.x / Globals.TILE_SIZE, viewport_size.y / Globals.TILE_SIZE)
	_map.set_all(Enums.TileType.Ground)
	
	var player_coord = Vector2i(_map.width, _map.height) / 2
	_map.mark_item(player_coord)
	
	
	for i in range(20): 
		while true:
			var rand_coord := Vector2i(randi_range(0, _map.width - 1), randi_range(0, _map.height - 1))
			if _map.get_item(rand_coord) == Enums.TileType.Ground && !_map.is_marked(rand_coord):
				_map.set_item(rand_coord, Enums.TileType.Wall)
				break

	var player: CharacterBody2D = player_scene.instantiate()
	player.position = Tools.to_center_pos(Vector2i(_map.width, _map.height) / 2)
	Globals.entity_container.add_child(player)
	
	for i in range(10):
		while true:
			var rand_coord := Vector2i(randi_range(0, _map.width - 1), randi_range(0, _map.height - 1))
			if _map.get_item(rand_coord) == Enums.TileType.Ground && !_map.is_marked(rand_coord):
				_map.mark_item(rand_coord)
				var monster = monster_scene.instantiate()
				monster.position = Tools.to_center_pos(rand_coord)
				Globals.entity_container.add_child(monster)
				break
	
	_map.clear_marks()
	
	State.on_game_start(
		_map,
		player)

	_create_new_block()
	
	game_running = true





func _create_new_block():
	if _block:
		_block.queue_free()
	
	_block = Tools.rand_item(block_scenes).instantiate()
	Globals.overlay_container.add_child(_block)
