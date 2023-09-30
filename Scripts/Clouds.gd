extends Node2D


@export var cloud_scene: PackedScene
@export var width := 512.0
@export var height := 128.0

@export var max_clouds := 10
@export var spawn_delta_min := 3.0
@export var spawn_delta_max := 6.0

var _spawn_cooldown := Cooldown.new()
var _clear_color


func _ready():	
	_spawn_cooldown.setup(self, randf_range(spawn_delta_min, spawn_delta_max), false)
	_clear_color = ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color")
	
	for i in range(max_clouds / 2):
		var y := randf_range(height / 2, get_viewport_rect().size.y - height / 2)
		var x := randf_range(0, get_viewport_rect().size.x)
		var pos := Vector2(x, y)
		_spawn_cloud(pos)


func _process(delta):
	if _spawn_cooldown.done:
		_spawn_cooldown.restart_with(randf_range(spawn_delta_min, spawn_delta_max))
		
		if get_child_count() < max_clouds:
			var y := randf_range(height / 2, get_viewport_rect().size.y - height / 2)
			var pos := Vector2(-width / 2, y)
			_spawn_cloud(pos)


func _spawn_cloud(pos: Vector2):
	var cloud := cloud_scene.instantiate()
			
	var z_index := randi_range(2, 10)
	var factor := 1.0 / (z_index / 2.0)
	
	cloud.modulate = _clear_color.lerp(Color.WHITE, factor)
	cloud.speed *= factor
	cloud.z_index = -z_index 

	cloud.position = pos
	add_child(cloud)
