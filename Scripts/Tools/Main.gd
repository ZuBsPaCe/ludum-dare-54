extends Node


@export var _initial_game_state := Enums.GameState.MAIN_MENU


@onready var _game_state := $GameState
@onready var _process := $Process
@onready var _game := $Game

@onready var _runner := Runner.new()


func _ready():
	get_tree().paused = true
	
	Globals.switch_game_state_requested.connect(switch_game_state)
	
	_game_state.setup(
		_initial_game_state,
		_on_GameStateMachine_enter_state,
		Callable(),
		_on_GameStateMachine_exit_state)
		
	_process.set_transition_overlay(Color.BLACK, 0.0)
	_process.set_transition_overlay(Color.TRANSPARENT, 1.0)


func switch_game_state(new_state):
	_game_state.set_state(new_state)
	

func _on_GameStateMachine_enter_state():
	match _game_state.current:
		Enums.GameState.MAIN_MENU:
			get_tree().paused = true
			_process.show_main_menu(0.5)

		Enums.GameState.GAME:
			_runner.abort()
			_runner = Runner.new()
			
			get_tree().paused = false
			Effects.shake(Vector2.RIGHT)
			
			await _game.start(_runner)
			_process.show_game_overlay(0.5)
			
		Enums.GameState.DEAD:
			_process.show_death_overlay(0.5)
		
		Enums.GameState.EXIT:
			get_tree().quit()

		_:
			assert(false, "Unknown game state")


func _on_GameStateMachine_exit_state():
	match _game_state.current:
		Enums.GameState.MAIN_MENU:
			_process.hide_main_menu(0.5)

		Enums.GameState.GAME:
			_process.hide_game_overlay(0.5)
		
		Enums.GameState.DEAD:
			_process.hide_death_overlay(0.5)

		_:
			assert(false, "Unknown game state")
