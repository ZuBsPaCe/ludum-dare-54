extends Node

const TILE_SIZE := 64.0
const HALF_TILE_SIZE := TILE_SIZE / 2.0

const SETTING_FULLSCREEN := "Fullscreen"
const SETTING_WINDOW_WIDTH := "Window Width"
const SETTING_WINDOW_HEIGHT := "Window Height"
const SETTING_MUSIC_VOLUME := "Music"
const SETTING_SOUND_VOLUME := "Sound"
const SETTING_DIFFICULTY := "Difficulty"

const GROUP_PLAYER := "Player"
const GROUP_MONSTER := "Monster"
const GROUP_BLOCK_TILE := "BlockTile"
const GROUP_FLAG := "Flag"
const GROUP_BULLET := "Bullet"


const SLIME_KILLED_SCORE := 200
const DRAGON_KILLED_SCORE := 500
const GHOST_OUTLIVED_SCORE := 1000
const TILE_SCORE := 10

var _center_node: Node2D
var _settings: Dictionary


signal switch_game_state_requested(new_state)
signal change_volume_requested(music_factor, sound_factor)


var entity_container: Node2D
var overlay_container: Node2D

var block_valid_color: Color
var block_invalid_color: Color

var heart_color: Color


var camera:Camera2D


func _ready():
	_center_node = Node2D.new()
	add_child(_center_node)


func setup(
	p_entity_container: Node2D,
	p_overlay_container: Node2D,
	p_block_valid_color: Color,
	p_block_invalid_color: Color,
	p_heart_color: Color):
	
	entity_container = p_entity_container
	overlay_container = p_overlay_container
	
	block_valid_color = p_block_valid_color
	block_invalid_color = p_block_invalid_color
	heart_color = p_heart_color
	
	var screen_size := DisplayServer.screen_get_size()
	
	@warning_ignore("integer_division")
	_settings = {
		Globals.SETTING_FULLSCREEN: true,
		Globals.SETTING_WINDOW_WIDTH: screen_size.x / 2,
		Globals.SETTING_WINDOW_HEIGHT: screen_size.y / 2,
		Globals.SETTING_MUSIC_VOLUME: 0.8,
		Globals.SETTING_SOUND_VOLUME: 0.8,
		Globals.SETTING_DIFFICULTY: Enums.Difficulty.Normal
	}
	
	Tools.load_data("settings.json", _settings)
	
	# Loaded as a float. Must cast to int, otherwise match statements don't work
	_settings[Globals.SETTING_DIFFICULTY] = int(_settings[Globals.SETTING_DIFFICULTY])


func get_setting(setting: String):
	return _settings[setting]


func set_setting(setting: String, value):
	_settings[setting] = value


func save_settings():
	Tools.save_data("settings.json", _settings)


func get_global_mouse_position() -> Vector2:
	return _center_node.get_global_mouse_position()


func switch_game_state(new_state):
	emit_signal("switch_game_state_requested", new_state)
	
func change_volume(music_factor, sound_factor):
	emit_signal("change_volume_requested", music_factor, sound_factor)
