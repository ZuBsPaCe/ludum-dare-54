extends CanvasLayer


var _music_factor: float
var _sound_factor: float


var _mode := Enums.MainMenuMode.Standard

@onready var _button1: Control = $%Button1
@onready var _button_label1: Label = $%ButtonLabel1

@onready var _button2: Control = $%Button2
@onready var _button_label2: Label = $%ButtonLabel2

@onready var _button3: Control = $%Button3
@onready var _button_label3: Label = $%ButtonLabel3

@onready var _difficulty := $%Difficulty
@onready var _difficulty_down: Control = $%DifficultyDown
@onready var _difficulty_up: Control = $%DifficultyUp
@onready var _difficulty_label: Label = $%DifficultyLabel

@onready var _music := $%Music
@onready var _music_down: Control = $%MusicDown
@onready var _music_up: Control = $%MusicUp
@onready var _music_label: Label = $%MusicLabel

@onready var _sound := $%Sound
@onready var _sound_down: Control = $%SoundDown
@onready var _sound_up: Control = $%SoundUp
@onready var _sound_label: Label = $%SoundLabel

@onready var _heart = $%Heart

@onready var _tilemaps := $%Tilemaps


@export var _unfocused_color := Color.GRAY
@export var _focused_color := Color.WHITE




func _ready():
	# https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
	if OS.has_feature("web"):
		get_node("%ExitButton").visible = false
	
	_register_focus_control(_button1, _button_label1, _on_button_1_gui_input)
	_register_focus_control(_button2, _button_label2, _on_button_2_gui_input)
	_register_focus_control(_button3, _button_label3, _on_button_3_gui_input)
	
	_register_focus_control(_difficulty, _difficulty_label, Callable())
	_register_focus_control(_difficulty_down, _difficulty_label, _on_difficulty_down_gui_input)
	_register_focus_control(_difficulty_up, _difficulty_label, _on_difficulty_up_gui_input)
	
	_register_focus_control(_music, _music_label, Callable())
	_register_focus_control(_music_down, _music_label, _on_music_down_gui_input)
	_register_focus_control(_music_up, _music_label, _on_music_up_gui_input)
	
	_register_focus_control(_sound, _sound_label, Callable())
	_register_focus_control(_sound_down, _sound_label, _on_sound_down_gui_input)
	_register_focus_control(_sound_up, _sound_label, _on_sound_up_gui_input)
	
	remove_child(_tilemaps)




func setup(main_menu_mode):
	_mode = main_menu_mode
	
	var hideButton3 := true
	
	match _mode:
		Enums.MainMenuMode.Standard:
			_button_label1.text = "New Game"
			_button_label2.text = "Tutorial"
			if OS.has_feature("web"):
				hideButton3 = true
			else:
				hideButton3 = false
				_button_label3.text = "Exit"
		
		Enums.MainMenuMode.Pause:
			_button_label1.text = "Continue"
			_button_label2.text = "New Game"
			if OS.has_feature("web"):
				hideButton3 = true
			else:
				hideButton3 = false
				_button_label3.text = "Exit"
		
		_:
			printerr("Unknown MainMenuMode")
	
	_button3.visible = !hideButton3
	
	_music_factor = Globals.get_setting(Globals.SETTING_MUSIC_VOLUME)
	_sound_factor = Globals.get_setting(Globals.SETTING_SOUND_VOLUME)
	
	_difficulty_label.text = State.get_difficulty_name(Globals.get_setting(Globals.SETTING_DIFFICULTY))
	_music_label.text = "Music %d %%" % int(_music_factor * 100)
	_sound_label.text = "Sound %d %%" % int(_sound_factor * 100)
	
	_heart.modulate = Globals.heart_color
	
	add_child(_tilemaps)
	

func teardown():
	remove_child(_tilemaps)


func _register_focus_control(
		control: Control,
		label: Label,
		gui_input_func: Callable):
	
	label.modulate = _unfocused_color
	
	control.focus_entered.connect(_on_focus_entered.bind(label))
	control.focus_exited.connect(_on_focus_exited.bind(label))
	
	control.mouse_entered.connect(_on_control_mouse_entered.bind(control))
	control.mouse_exited.connect(_on_control_mouse_exited.bind(control))
	
	if gui_input_func.is_valid():
		control.gui_input.connect(gui_input_func)


func _on_focus_entered(label: Label):
	label.modulate = _focused_color

func _on_focus_exited(label: Label):
	label.modulate = _unfocused_color

func _on_control_mouse_entered(control: Control):
	control.grab_focus()

func _on_control_mouse_exited(control: Control):
	control.release_focus()




func _on_button_1_gui_input(event):
	if !event.is_action("left_click") or !event.is_pressed() or event.is_echo():
		return
		
	match _mode:		
		Enums.MainMenuMode.Standard:
			Globals.switch_game_state(Enums.GameState.GAME)
		
		Enums.MainMenuMode.Pause:
			Globals.switch_game_state(Enums.GameState.CONTINUE)
		
		_:
			printerr("Unknown MainMenuMode")



func _on_button_2_gui_input(event):
	if !event.is_action("left_click") or !event.is_pressed() or event.is_echo():
		return
		
	match _mode:
		Enums.MainMenuMode.Standard:
			Globals.switch_game_state(Enums.GameState.START_TUTORIAL)
		
		Enums.MainMenuMode.Pause:
			Globals.switch_game_state(Enums.GameState.GAME)
		
		_:
			printerr("Unknown MainMenuMode")


func _on_button_3_gui_input(event):
	if !event.is_action("left_click") or !event.is_pressed() or event.is_echo():
		return
		
	match _mode:
		Enums.MainMenuMode.Standard:
			Globals.switch_game_state(Enums.GameState.EXIT)
		
		Enums.MainMenuMode.Pause:
			Globals.switch_game_state(Enums.GameState.EXIT)
		
		_:
			printerr("Unexpected MainMenuMode")


func _on_difficulty_down_gui_input(event):
	if !event.is_action("left_click") or !event.is_pressed() or event.is_echo():
		return
	
	State.decrease_difficulty()
	_difficulty_label.text = State.get_difficulty_name(Globals.get_setting(Globals.SETTING_DIFFICULTY))

func _on_difficulty_up_gui_input(event):
	if !event.is_action("left_click") or !event.is_pressed() or event.is_echo():
		return
	
	State.increase_difficulty()
	_difficulty_label.text = State.get_difficulty_name(Globals.get_setting(Globals.SETTING_DIFFICULTY))


func _on_music_down_gui_input(event):
	if !event.is_action("left_click") or !event.is_pressed() or event.is_echo():
		return
	
	_music_factor = clampf(_music_factor - 0.1, 0, 1)
	_music_factor = roundf(_music_factor * 10) / 10.0
	Globals.change_volume(_music_factor, _sound_factor)
	_music_label.text = "Music %d %%" % int(_music_factor * 100)
	
	
func _on_music_up_gui_input(event):
	if !event.is_action("left_click") or !event.is_pressed() or event.is_echo():
		return
	
	_music_factor = clampf(_music_factor + 0.1, 0, 1)
	_music_factor = roundf(_music_factor * 10) / 10.0
	Globals.change_volume(_music_factor, _sound_factor)
	_music_label.text = "Music %d %%" % int(_music_factor * 100)

func _on_sound_down_gui_input(event):
	if !event.is_action("left_click") or !event.is_pressed() or event.is_echo():
		return
	
	_sound_factor = clampf(_sound_factor - 0.1, 0, 1)
	_sound_factor = roundf(_sound_factor * 10) / 10.0
	Globals.change_volume(_music_factor, _sound_factor)
	_sound_label.text = "Sound %d %%" % int(_sound_factor * 100)


func _on_sound_up_gui_input(event):
	if !event.is_action("left_click") or !event.is_pressed() or event.is_echo():
		return
	
	_sound_factor = clampf(_sound_factor + 0.1, 0, 1)
	_sound_factor = roundf(_sound_factor * 10) / 10.0
	Globals.change_volume(_music_factor, _sound_factor)
	_sound_label.text = "Sound %d %%" % int(_sound_factor * 100)
#
#func _on_button_1_focus_entered():
#	_button_label1.modulate = _focused_color
#
#func _on_button_1_focus_exited():
#	_button_label1.modulate = _unfocused_color
#
#func _on_button_1_mouse_entered():
#	_button1.grab_focus()
#
#func _on_button_1_mouse_exited():
#	_button1.release_focus()
#
#
#func _on_button_2_focus_entered():
#	_button_label2.modulate = _focused_color
#
#func _on_button_2_focus_exited():
#	_button_label2.modulate = _unfocused_color
#
#func _on_button_2_mouse_entered():
#	_button2.grab_focus()
#
#func _on_button_2_mouse_exited():
#	_button2.release_focus()
#
#
#func _on_button_3_focus_entered():
#	_button_label3.modulate = _focused_color
#
#func _on_button_3_focus_exited():
#	_button_label3.modulate = _unfocused_color
#
#func _on_button_3_mouse_entered():
#	_button3.grab_focus()
#
#func _on_button_3_mouse_exited():
#	_button3.release_focus()
#
#
#
#func _on_difficulty_focus_entered():
#	_difficulty_label.modulate = _focused_color
#
#
#func _on_difficulty_focus_exited():
#	_difficulty_label.modulate = _unfocused_color
#
#
#func _on_difficulty_mouse_entered():
#	_difficulty.grab_focus()
#
#
#func _on_difficulty_mouse_exited():
#	_difficulty.release_focus()
#
#
#func _on_difficulty_down_focus_entered():
#	_difficulty_label.modulate = _focused_color
#
#
#func _on_difficulty_down_focus_exited():
#	_difficulty_down.modulate = _unfocused_color
#
#
#func _on_difficulty_down_mouse_entered():
#	_difficulty_down.grab_focus()
#
#
#func _on_difficulty_down_mouse_exited():
#	_difficulty_down.release_focus()
#
#
#
#
#func _on_difficulty_up_focus_entered():
#	_difficulty_label.modulate = _focused_color
#
#
#func _on_difficulty_up_focus_exited():
#	_difficulty_label.modulate = _unfocused_color
#
#
#func _on_difficulty_up_mouse_entered():
#	_difficulty_up.grab_focus()
#
#
#func _on_difficulty_up_mouse_exited():
#	_difficulty_up.release_focus()
#
#
#
#
#func _on_music_focus_entered():
#	_music_label.modulate = _focused_color
#
#
#func _on_music_focus_exited():
#	_music_label.modulate = _unfocused_color
#
#
#func _on_music_mouse_entered():
#	_music_label.grab_focus()
#
#
#func _on_music_mouse_exited():
#	_music_label.release_focus()
#
#
#func _on_music_down_focus_entered():
#	_music_label.modulate = _focused_color
#
#
#func _on_music_down_focus_exited():
#	_music_label.modulate = _unfocused_color
#
#
#func _on_music_down_mouse_entered():
#	_music_down.grab_focus()
#
#
#func _on_music_down_mouse_exited():
#	_music_down.release_focus()
#
#
#
#func _on_music_up_focus_entered():
#	_music_label.modulate = _focused_color
#
#
#func _on_music_up_focus_exited():
#	_music_label.modulate = _unfocused_color
#
#
#func _on_music_up_mouse_entered():
#	_music_up.grab_focus()
#
#
#func _on_music_up_mouse_exited():
#	_music_up.release_focus()
#
#
#
#
#func _on_sound_focus_entered():
#	_sound_label.modulate = _focused_color
#
#
#func _on_sound_focus_exited():
#	_sound_label.modulate = _unfocused_color
#
#
#func _on_sound_mouse_entered():
#	_sound
#
#
#func _on_sound_mouse_exited():
#	pass # Replace with function body.
#
#
#func _on_sound_down_focus_entered():
#	_sound_label.modulate = _focused_color
#
#
#func _on_sound_down_focus_exited():
#	_sound_label.modulate = _unfocused_color
#
#
#func _on_sound_down_mouse_entered():
#	_sound_down.grab_focus()
#
#
#func _on_sound_down_mouse_exited():
#	_sound_down.release_focus()
#
#
#
#
#func _on_sound_up_focus_entered():
#	_sound_label.modulate = _focused_color
#
#
#func _on_sound_up_focus_exited():
#	_sound_label.modulate = _unfocused_color
#
#
#func _on_sound_up_mouse_entered():
#	_sound_up.grab_focus()
#
#
#func _on_sound_up_mouse_exited():
#	_sound_up.release_focus()


