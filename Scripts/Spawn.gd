extends Node2D

var _runner: Runner

func setup(runner: Runner, monster_type, coord: Vector2i, wait_secs: float) -> void:
	
	runner.create_timer(self, wait_secs)
	if !await runner.proceed:
		return
	
	State.add_monster(coord, monster_type)
	queue_free()
