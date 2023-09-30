extends Node

const TILE_SIZE := 64.0
const HALF_TILE_SIZE := TILE_SIZE / 2.0

const SETTING_FULLSCREEN := "Fullscreen"
const SETTING_WINDOW_WIDTH := "Window Width"
const SETTING_WINDOW_HEIGHT := "Window Height"
const SETTING_MUSIC_VOLUME := "Music"
const SETTING_SOUND_VOLUME := "Sound"

const GROUP_PLAYER := "Player"
const GROUP_MONSTER := "Monster"


var _center_node: Node2D
var _settings: Dictionary


signal switch_game_state_requested(new_state)
signal change_volume_requested(music_factor, sound_factor)


var entity_container: Node2D
var overlay_container: Node2D

var block_valid_color: Color
var block_invalid_color: Color

var heart_color: Color


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
		Globals.SETTING_SOUND_VOLUME: 0.8
	}
	
	Tools.load_data("settings.json", _settings)


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