extends Node2D


const GameState := preload("res://Scripts/Tools/Examples/ExampleGameState.gd").GameState

@export var player_scene: PackedScene
@export var monster_scene: PackedScene
@export var spawn_scene: PackedScene

@export var block_scenes: Array[PackedScene]

@onready var _tilemap := $Tilemap

var _map: Map

var _block: Block

var _runner: Runner

var _spawn_cooldown := Cooldown.new()

var game_running := false

func _ready():
	Effects.setup($Camera2D)
	
	State.setup(
		$Tilemap,
		player_scene,
		monster_scene,
		spawn_scene)
	
	Globals.switch_game_state_requested.connect(_on_switch_game_state_requested)


func _on_switch_game_state_requested(new_state):
	if new_state != Enums.GameState.GAME:
		game_running = false


func _process(delta):
	if game_running:
		var mouse_pos := get_global_mouse_position()
		var mouse_coord := Tools.to_coord(mouse_pos)
		
		if Input.is_action_just_pressed("turn_left"):
			_block.turn_left()
		elif Input.is_action_just_pressed("turn_right"):
			_block.turn_right()
		
		_block.update_mouse_pos(mouse_pos)
		
		if _block.valid and Input.is_action_just_pressed("apply_block"):
			_block.apply()
			_create_new_block()
			
		if _spawn_cooldown.done:
			State.add_spawn_group()
			_spawn_cooldown.restart()


# Can yield
func start(runner: Runner):
	game_running = false
	_runner = runner
	
#	runner.create_tween(self).tween_property($Dummy, "position", Vector2(Tools.get_visible_rect().get_center()), 1.0)
#	if !await runner.proceed:
#		return
#
#	runner.create_timer(self, 1.0)
#	if !await runner.proceed:
#		return

	State.on_game_reset()
	
	
	var viewport_size := get_viewport_rect().size

	_map = Map.new(viewport_size.x / Globals.TILE_SIZE, viewport_size.y / Globals.TILE_SIZE)
	_map.set_all(Enums.TileType.Ground)
	
	for x in range(_map.width):
		_map.set_item_xy(x, 0, Enums.TileType.ForcedEmpty)
		_map.set_item_xy(x, _map.height - 1, Enums.TileType.ForcedEmpty)
	
	for y in range(_map.height):
		_map.set_item_xy(0, y, Enums.TileType.ForcedEmpty)
		_map.set_item_xy(_map.width - 1, y, Enums.TileType.ForcedEmpty)
	
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
	
	_map.clear_marks()
	
	State.on_game_start(
		_runner,
		_map,
		player)

	_create_new_block()
	
	_spawn_cooldown.setup(self, 5, false)
	
	game_running = true



func _create_new_block():
	if _block:
		_block.queue_free()
	
	_block = Tools.rand_item(block_scenes).instantiate()
	Globals.overlay_container.add_child(_block)
	_block.setup(randf() < 0.5)
