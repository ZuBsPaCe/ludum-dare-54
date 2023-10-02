extends CharacterBody2D


@export var speed := 100.0
@export var monster_type := Enums.MonsterType.Slime
@export var shoot_distance := 512.0

@onready var animation_player := $AnimationPlayer
@onready var sprites := $Sprites


var _runner: Runner

var _headingLeft := false

var _dragon_head_cooldown := Cooldown.new()
var _dragon_fire_cooldown := Cooldown.new()
var _dragon_shoot_cooldown := Cooldown.new()

var _ghost_velocity := Vector2.ZERO
var _ghost_alive_cooldown := Cooldown.new()


func _ready():
	if monster_type == Enums.MonsterType.Dragon:
		_dragon_head_cooldown.setup(self, randf() * 1.1, false)
		_dragon_fire_cooldown.setup(self, randf() * 3, false)
		_dragon_shoot_cooldown.setup(self, 0.5, true)
	elif monster_type == Enums.MonsterType.Ghost:
		_ghost_alive_cooldown.setup(self, 30, false)

func setup(runner: Runner):
	_runner = runner


func _physics_process(delta):
	var player_vec := State.player_pos - position
	
	match monster_type:
		Enums.MonsterType.Slime:
			var move_vec := player_vec.normalized() * speed
			
			velocity = move_vec
			move_and_slide()
			
			if velocity.x > 0:
				_headingLeft = false
				animation_player.play("RunRight")
			elif velocity.x < 0:
				_headingLeft = true
				animation_player.play("RunLeft")
			elif velocity.y != 0:
				if _headingLeft:
					animation_player.play("RunLeft")
				else:
					animation_player.play("RunRight")
			
			var coord := Tools.to_coord(position)
			if State.is_valid_tile(coord):
				if State.is_tile(coord, Enums.TileType.Empty) or State.is_tile(coord, Enums.TileType.ForcedEmpty):
					queue_free()
					
					State.add_slime_killed()

		
		Enums.MonsterType.Dragon:
			if _dragon_fire_cooldown.done:
				
				if player_vec.length() <= shoot_distance:
					var look_dir := player_vec.normalized()
					
					if look_dir.x >= 0:
						sprites.scale = Vector2(1, 1)
					else:
						sprites.scale = Vector2(-1, 1)
					
					animation_player.play("Fire")
					_dragon_shoot_cooldown.restart()
					_dragon_fire_cooldown.restart_with(3)
					_dragon_head_cooldown.restart_with(1.1)
					
					State.add_bullet(position + Vector2.UP * Globals.TILE_SIZE * 0.3, look_dir)
				else:
					_dragon_fire_cooldown.restart_with(0.5)
			
			
			if _dragon_shoot_cooldown.done:
				animation_player.play("Idle")
				
				if _dragon_head_cooldown.done:
					var look_dir := player_vec.normalized()
					
					if look_dir.x >= 0:
						sprites.scale = Vector2(1, 1)
					else:
						sprites.scale = Vector2(-1, 1)
					
					if randf() < 0.25:
						sprites.scale = Vector2(sprites.scale.x * -1, sprites.scale.y)
					
					_dragon_head_cooldown.restart_with(1.1)
		
		Enums.MonsterType.Ghost:
			if !_ghost_alive_cooldown.done:
			
				var target_velocity := player_vec.normalized() * speed
				velocity = velocity.move_toward(target_velocity, speed * delta)

				move_and_slide()
				
				if player_vec.x > 0:
					sprites.scale = Vector2(-1, 1)
				else:
					sprites.scale = Vector2(1, 1)
			else:
				State.add_ghost_outlived()
				set_physics_process(false)
				
				var tween := _runner.create_tween(self)
				tween.tween_property(self, "modulate", Tools.get_alpha_0(modulate), 3.0)
				await tween.finished
				queue_free()
					
