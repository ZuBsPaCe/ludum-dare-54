extends CanvasLayer


const GameState := preload("res://Scripts/Tools/Examples/ExampleGameState.gd").GameState

@export var player_scene: PackedScene
@export var slime_scene: PackedScene
@export var dragon_scene: PackedScene
@export var ghost_scene: PackedScene
@export var bullet_scene: PackedScene
@export var spawn_scene: PackedScene
@export var flag_scene: PackedScene

@export var block_scenes: Array[PackedScene]

@onready var helper:= $%Helper
@onready var ground_tilemap := $%GroundTilemap
@onready var wall_tilemap := $%WallTilemap

var _map: Map

var _block: Block
var _block_up := true
var _can_toggle_block_up := true

var _runner: Runner

var _spawn_cooldown := Cooldown.new()
var _block_cooldown := Cooldown.new()

var game_running := false
var game_mode


var _predefined_blocks_index := 0
var _predefined_blocks_callback: Callable




func _ready():
	Effects.setup($Camera2D)
	
	wall_tilemap.clear()
	ground_tilemap.clear()
	
	State.setup(
		wall_tilemap,
		ground_tilemap,
		player_scene,
		slime_scene,
		dragon_scene,
		ghost_scene,
		bullet_scene,
		spawn_scene)
	
	Globals.switch_game_state_requested.connect(_on_switch_game_state_requested)
	
	Globals.camera = $Camera2D 


func _on_switch_game_state_requested(new_state):
	game_running = new_state == Enums.GameState.GAME


func _process(delta):
	if game_running:
		State.duration_secs += delta
		
		if _block != null:
			
			if !State.block_disabled:
				_block.visible = true
			
				var mouse_pos :Vector2= helper.get_global_mouse_position()
				var mouse_coord := Tools.to_coord(mouse_pos)
				
				if _can_toggle_block_up and Input.is_action_just_pressed("toggle_block_up") and _block_cooldown.done:
					_block_cooldown.restart_with(0.1)
					_block_up = !_block_up
					_block.change_up(_block_up)
				
				if Input.is_action_just_pressed("turn_left"):
					_block.turn_left()
				elif Input.is_action_just_pressed("turn_right"):
					_block.turn_right()
				
				_block.update_mouse_pos(mouse_pos)
				
				if _block.valid and Input.is_action_just_pressed("apply_block") and _block_cooldown.done:
					_block_cooldown.restart_with(0.1)
					
					_block.apply()
					_explode_block()
					_create_new_block()
			else:
				_block.visible = false

			
		if game_mode == Enums.GameMode.GAME:
			if _spawn_cooldown.done:
				State.add_spawn_group()
				
				var spawn_interval = 10
				if State.difficulty == Enums.Difficulty.Easy:
					spawn_interval = 15
				elif State.difficulty == Enums.Difficulty.Normal:
					spawn_interval = 10
				elif State.difficulty == Enums.Difficulty.Hard:
					spawn_interval = 5
				_spawn_cooldown.restart_with(spawn_interval)


# Can yield
func start(p_runner: Runner, p_game_mode, tutorial_level := -1):
	game_running = false
	game_mode = p_game_mode
	
	_runner = p_runner
	
	_predefined_blocks_callback = Callable()
	_predefined_blocks_index = 0
	
	_block_up = true
	_can_toggle_block_up = true
	
#	runner.create_tween(self).tween_property($Dummy, "position", Vector2(Tools.get_visible_rect().get_center()), 1.0)
#	if !await runner.proceed:
#		return
#
#	runner.create_timer(self, 1.0)
#	if !await runner.proceed:
#		return

	State.on_game_reset()
	
	var viewport_size :Vector2= helper.get_viewport_rect().size
	_map = Map.new(viewport_size.x / Globals.TILE_SIZE, viewport_size.y / Globals.TILE_SIZE)
	
	var player: CharacterBody2D
	
	var border := 1
	
	var center_x := _map.width / 2
	var center_y := _map.height / 2
	
	var area_width := _map.width - 2 * border
	var area_height := _map.height - 2 * border
	
	var half_area_width := area_width / 2
	var half_area_height := area_height / 2
	
	var third_area_width := area_width / 3
	var third_area_height := area_height / 3
	
	var fourth_area_width := area_width / 4
	var fourth_area_height := area_height / 4
	
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

	if game_mode == Enums.GameMode.GAME:
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

		player = player_scene.instantiate()
		player.position = Tools.to_center_pos(Vector2i(_map.width, _map.height) / 2)
		Globals.entity_container.add_child(player)
		
	elif game_mode == Enums.GameMode.TUTORIAL:
		assert(tutorial_level >= 0)
		
		_can_toggle_block_up = false
		#tutorial_level = 4
		
		if tutorial_level == 0:
			_map.set_all(Enums.TileType.Empty)
			
			var start_coord := Vector2i(fourth_area_width, fourth_area_height * 3)
			
			for offset_x in range(-1, 2):
				for offset_y in range(-1, 1):
					_map.set_item(start_coord + Vector2i(offset_x, offset_y), Enums.TileType.Ground)
			
			var end_coord := Vector2i(center_x + 2, fourth_area_height * 3)

			for offset_x in range(-1, 2):
				for offset_y in range(-1, 1):
					_map.set_item(end_coord + Vector2i(offset_x, offset_y), Enums.TileType.Ground)
			
			var flag := flag_scene.instantiate()
			flag.position = Tools.to_pos(end_coord + Vector2i.RIGHT)
			Globals.entity_container.add_child(flag)

			for coord_x in range(end_coord.x - 1, end_coord.x + 3):
				for coord_y in range(start_coord.y - 2, end_coord.y + 2):
					if (coord_x == end_coord.x + 2 or
						coord_y == start_coord.y - 2 or
						coord_y == end_coord.y + 1):

						_map.set_item_xy(coord_x, coord_y, Enums.TileType.Wall)
			
			var i = 0
			for coord_x in range(start_coord.x + 1, end_coord.x):
				if i < 2 or i > 4:
					_map.set_item_xy(coord_x, start_coord.y - 1, Enums.TileType.Ground)
					_map.set_item_xy(coord_x, start_coord.y, Enums.TileType.Ground)
					
					if i == 1:
						_map.set_item_xy(coord_x, start_coord.y - 2, Enums.TileType.Ground)
						_map.set_item_xy(coord_x, start_coord.y - 3, Enums.TileType.Ground)
					elif i == 5:
						_map.set_item_xy(coord_x, start_coord.y + 2, Enums.TileType.Ground)
						_map.set_item_xy(coord_x, start_coord.y + 1, Enums.TileType.Ground)
				elif i == 2 :
					_map.set_item_xy(coord_x, start_coord.y - 3, Enums.TileType.Ground)
				elif i == 3:
					_map.set_item_xy(coord_x, start_coord.y - 3, Enums.TileType.Ground)
					_map.set_item_xy(coord_x, start_coord.y - 2, Enums.TileType.Ground)
					_map.set_item_xy(coord_x, start_coord.y - 1, Enums.TileType.Ground)
					_map.set_item_xy(coord_x, start_coord.y + 0, Enums.TileType.Ground)
					_map.set_item_xy(coord_x, start_coord.y + 1, Enums.TileType.Ground)
					_map.set_item_xy(coord_x, start_coord.y + 2, Enums.TileType.Ground)
				elif i <= 5:
					_map.set_item_xy(coord_x, start_coord.y + 2, Enums.TileType.Ground)


				i += 1

	
			player = player_scene.instantiate()
			player.position = Tools.to_center_pos(start_coord)
			Globals.entity_container.add_child(player)

		
		elif tutorial_level == 1:
			_map.set_all(Enums.TileType.Empty)
			
			var start_coord := Vector2i(center_x - 3, fourth_area_height * 3)
			
			for offset_x in range(-1, 2):
				for offset_y in range(-1, 1):
					_map.set_item(start_coord + Vector2i(offset_x, offset_y), Enums.TileType.Ground)
			
			var end_coord := Vector2i(center_x + 2, fourth_area_height * 3)

			for offset_x in range(-1, 2):
				for offset_y in range(-1, 1):
					_map.set_item(end_coord + Vector2i(offset_x, offset_y), Enums.TileType.Ground)
			
			var flag := flag_scene.instantiate()
			flag.position = Tools.to_pos(end_coord + Vector2i.RIGHT)
			Globals.entity_container.add_child(flag)

			for coord_x in range(start_coord.x - 2, end_coord.x + 3):
				for coord_y in range(start_coord.y - 2, end_coord.y + 2):
					if (coord_x == start_coord.x - 2 or
						coord_x == end_coord.x + 2 or
						coord_y == start_coord.y - 2 or
						coord_y == end_coord.y + 1):

						_map.set_item_xy(coord_x, coord_y, Enums.TileType.Wall)
	#
			player = player_scene.instantiate()
			player.position = Tools.to_center_pos(start_coord)
			Globals.entity_container.add_child(player)
			
			_predefined_blocks_callback = func (index:int):
				var done := true
				for check_x in range(start_coord.x, end_coord.x + 1):
					if !_map.is_item_xy(check_x, start_coord.y, Enums.TileType.Ground):
						done = false
						break
				if !done:
					return BlockDefinition.new(3, true, 0)
				else:
					return null
					
		elif tutorial_level == 2:
			_map.set_all(Enums.TileType.Empty)
			
			var start_coord := Vector2i(center_x - 3 - 1, fourth_area_height * 3)
			
			for offset_x in range(-1, 2):
				for offset_y in range(-1, 2):
					_map.set_item(start_coord + Vector2i(offset_x, offset_y), Enums.TileType.Ground)
					
			
			var end_coord := Vector2i(center_x + 2 + 1, fourth_area_height * 3)

			for offset_x in range(-1, 2):
				for offset_y in range(-1, 2):
					_map.set_item(end_coord + Vector2i(offset_x, offset_y), Enums.TileType.Ground)
			
			var flag := flag_scene.instantiate()
			flag.position = Tools.to_center_pos(end_coord)
			Globals.entity_container.add_child(flag)

			for coord_x in range(start_coord.x - 2, end_coord.x + 3):
				for coord_y in range(start_coord.y - 2, end_coord.y + 3):
					if (coord_x == start_coord.x - 2 or
						coord_x == end_coord.x + 2 or
						coord_y == start_coord.y - 2 or
						coord_y == end_coord.y + 2):

						_map.set_item_xy(coord_x, coord_y, Enums.TileType.Wall)
			
			player = player_scene.instantiate()
			player.position = Tools.to_center_pos(start_coord)
			Globals.entity_container.add_child(player)
			
			_predefined_blocks_callback = func (index:int):
				var done := false
				
				for offset_y in range(-1, 2):
					var all_filled := true
					for check_x in range(start_coord.x, end_coord.x):
						if !_map.is_item_xy(check_x, start_coord.y + offset_y, Enums.TileType.Ground):
							all_filled = false
							break
					if all_filled:
						done = true
						break
						
				if !done:
					var first_placed := false
					
					for offset_y in range(-1, 2):
						for check_x in range(start_coord.x + 2, end_coord.x - 1):
							if _map.is_item_xy(check_x, start_coord.y + offset_y, Enums.TileType.Ground):
								first_placed = true
								break
						if first_placed:
							break
					
					if !first_placed:
						return BlockDefinition.new(3, true, 0)
					else:
						return BlockDefinition.new(6, true, 1)
				else:
					return null
		
		elif tutorial_level == 3:
			_map.set_all(Enums.TileType.Empty)
			
			var start_coord := Vector2i(fourth_area_width, fourth_area_height * 3)
			
			for offset_x in range(-1, 2):
				for offset_y in range(-1, 1):
					_map.set_item(start_coord + Vector2i(offset_x, offset_y), Enums.TileType.Ground)
			
			var end_coord := Vector2i(fourth_area_width * 3, fourth_area_height * 3)

			for offset_x in range(-1, 2):
				for offset_y in range(-1, 1):
					_map.set_item(end_coord + Vector2i(offset_x, offset_y), Enums.TileType.Ground)
			
			var flag := flag_scene.instantiate()
			flag.position = Tools.to_pos(end_coord + Vector2i.RIGHT)
			Globals.entity_container.add_child(flag)

			var mountain_coords := []
			
			for coord_x in range(start_coord.x + 2, end_coord.x - 1):
				for coord_y in range(start_coord.y - 4, end_coord.y + 4):
					if coord_x > start_coord.x + 2 && coord_x < end_coord.x - 2:
						_map.set_item_xy(coord_x, coord_y, Enums.TileType.Wall)
						mountain_coords.append(Vector2i(coord_x, coord_y))
					else:
						_map.set_item_xy(coord_x, coord_y, Enums.TileType.Ground)
			
			mountain_coords.shuffle()
			for i in range(4):
				_map.set_item(mountain_coords[i], Enums.TileType.Ground)
				mountain_coords.remove_at(i)
				
			
			
			for coord_x in range(start_coord.x - 1, start_coord.x + 6):
				for coord_y in range(start_coord.y - 2, end_coord.y + 2):
					if (coord_x == start_coord.x - 1 or
						coord_y == start_coord.y - 2 or
						coord_y == end_coord.y + 1):

						_map.set_item_xy(coord_x, coord_y, Enums.TileType.Wall)
			
	
			player = player_scene.instantiate()
			player.position = Tools.to_center_pos(start_coord)
			Globals.entity_container.add_child(player)
			
			_can_toggle_block_up = true
			
			_predefined_blocks_callback = func (index:int):
				var all_block_definitions:= []
				all_block_definitions.append(BlockDefinition.new(0, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(1, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(2, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(3, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(4, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(5, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(6, _block_up, -1))
				return Tools.rand_item(all_block_definitions)
		
		elif tutorial_level == 4:
			_map.set_all(Enums.TileType.Empty)
			
			var start_coord := Vector2i(fourth_area_width, fourth_area_height * 3)
			
			for offset_x in range(-1, 2):
				for offset_y in range(-1, 2):
					_map.set_item(start_coord + Vector2i(offset_x, offset_y), Enums.TileType.Ground)
			
			var end_coord := Vector2i(fourth_area_width * 3, fourth_area_height * 3)

			for offset_x in range(-1, 2):
				for offset_y in range(-1, 2):
					_map.set_item(end_coord + Vector2i(offset_x, offset_y), Enums.TileType.Ground)
			
			var flag := flag_scene.instantiate()
			flag.position = Tools.to_pos(end_coord + Vector2i.RIGHT)
			Globals.entity_container.add_child(flag)
			
			var spawn_coords := []
			
			for coord_x in range(start_coord.x + 2, end_coord.x - 1):
				for coord_y in range(start_coord.y - 4, end_coord.y + 4):
					_map.set_item_xy(coord_x, coord_y, Enums.TileType.Ground)
					
					if coord_x > start_coord.x + 4:
						spawn_coords.append(Vector2i(coord_x, coord_y))
			
			
			for coord_x in range(start_coord.x - 2, start_coord.x + 2):
				for coord_y in range(start_coord.y - 2, end_coord.y + 2):
					if (coord_x == start_coord.x - 2 or
						coord_x == end_coord.x + 2 or
						coord_y == start_coord.y - 2 or
						coord_y == end_coord.y + 1):

						_map.set_item_xy(coord_x, coord_y, Enums.TileType.Wall)
			
			for coord_y in range(start_coord.y - 3, end_coord.y + 3):
				_map.set_item_xy(start_coord.x + 3, coord_y, Enums.TileType.Wall)
			
			
			spawn_coords.shuffle()
			for i in range(5):
				_map.set_item(spawn_coords.pop_front(), Enums.TileType.Wall)
			
			for i in range(15):
				State.add_spawn(_runner, Enums.MonsterType.Dragon, spawn_coords.pop_front())
			
	
			player = player_scene.instantiate()
			player.position = Tools.to_center_pos(start_coord)
			Globals.entity_container.add_child(player)
			
			_can_toggle_block_up = true
			
			_predefined_blocks_callback = func (index:int):
				var all_block_definitions:= []
				all_block_definitions.append(BlockDefinition.new(0, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(1, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(2, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(3, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(4, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(5, _block_up, -1))
				all_block_definitions.append(BlockDefinition.new(6, _block_up, -1))
				return Tools.rand_item(all_block_definitions)
		else:
			printerr("Unexpected tutorial level")

	
	else:
		printerr("Unknown GameMode")
	
	_map.clear_marks()
	
	State.on_game_start(
		_runner,
		game_mode,
		tutorial_level,
		_map,
		player)

	_create_new_block()
	
	var spawn_interval = 10
	if State.difficulty == Enums.Difficulty.Easy:
		spawn_interval = 15
	elif State.difficulty == Enums.Difficulty.Normal:
		spawn_interval = 10
	elif State.difficulty == Enums.Difficulty.Hard:
		spawn_interval = 5
	
	_spawn_cooldown.setup(self, spawn_interval, false)
	_block_cooldown.setup(self, 1.0, false)


func _explode_block():
	var block = _block
	_block = null
	
	State.sounds.play(Enums.Sounds.Block, block.position)
	
	block.explode()
	_runner.create_timer(self, 2.0)
	if !await _runner.proceed:
		return
	
	block.queue_free()


func _create_new_block():
	if _block:
		_block.queue_free()
		_block = null
	
	if game_mode == Enums.GameMode.GAME:
		_block = Tools.rand_item(block_scenes).instantiate()
		Globals.overlay_container.add_child(_block)
		_block.setup(_block_up)
	else:
		if _predefined_blocks_callback.is_valid():
			var ret = _predefined_blocks_callback.call(_predefined_blocks_index)
			if ret != null:
				var block_definition:BlockDefinition = ret
				_block = block_scenes[block_definition.block_index].instantiate()
				Globals.overlay_container.add_child(_block)
				_block.setup(block_definition.up, block_definition.rotation_counter)
				
				_predefined_blocks_index += 1
