extends Node2D


const GameState := preload("res://Scripts/Tools/Examples/ExampleGameState.gd").GameState

@export var player_scene: PackedScene
@export var monster_scene: PackedScene

@onready var _tilemap := $Tilemap


var game_running := false
func _ready():	
	Effects.setup($Camera2D)


func _process(delta):
#	if game_running:
#		$Dummy.position += $Dummy.position.direction_to(Globals.get_global_mouse_position()) * 100.0 * delta
#	$Dummy.rotation = PI * 0.5 + $Dummy.position.angle_to_point(Globals.get_global_mouse_position())

	pass


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

	var map := Map.new(viewport_size.x / Globals.TILE_SIZE, viewport_size.y / Globals.TILE_SIZE)
	map.set_all(Enums.TileType.Ground)
	
	var player_coord = Vector2i(map.width, map.height) / 2
	map.mark_item(player_coord)
	
	for i in range(20): 
		while true:
			var rand_coord := Vector2i(randi_range(0, map.width - 1), randi_range(0, map.height - 1))
			if map.get_item(rand_coord) == Enums.TileType.Ground && !map.is_marked(rand_coord):
				map.set_item(rand_coord, Enums.TileType.Wall)
				break

	var player: CharacterBody2D = player_scene.instantiate()
	player.position = Tools.to_center_pos(Vector2i(map.width, map.height) / 2)
	Globals.entity_container.add_child(player)
	
	State.player = player
	
	for i in range(10):
		while true:
			var rand_coord := Vector2i(randi_range(0, map.width - 1), randi_range(0, map.height - 1))
			if map.get_item(rand_coord) == Enums.TileType.Ground && !map.is_marked(rand_coord):
				map.mark_item(rand_coord)
				var monster = monster_scene.instantiate()
				monster.position = Tools.to_center_pos(rand_coord)
				Globals.entity_container.add_child(monster)
				break
	
	map.clear_marks()
	for y in map.height:
		for x in map.width:
			var coord := Vector2i(x, y)
			match map.get_item(coord):
				Enums.TileType.Ground:
					_tilemap.set_cell(0, coord, 0, Vector2i(0, 0))
				Enums.TileType.Wall:
					_tilemap.set_cell(0, coord, 0, Vector2i(1, 0))
				_:
					printerr("Unknown TileType")
	
	
	game_running = true
