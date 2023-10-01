extends CanvasLayer


@onready var _score_value := $%ScoreValue
@onready var _duration_value := $%DurationValue
@onready var _slimes_killed_value := $%SlimesKilledValue
@onready var _dragons_killed_value := $%DragonsKilledValue
@onready var _ghosts_outlived_value := $%GhostsOutlivedValue


func setup():
	_score_value.text = str(State.score)
	
	var hours := 0
	var minutes := 0
	var seconds := 0
	
	var secs = State.duration_secs
	while secs > 3600:
		hours += 1
		secs -= 3600
	
	while secs > 60:
		minutes += 1
		secs -= 60
	
	seconds = ceil(secs)
	
	var duration := ""
	if hours > 0:
		duration = "%dh %02dm %02ds" % [hours, minutes, seconds]
	elif minutes > 0:
		duration = "%02dm %02ds" % [minutes, seconds]
	else:
		duration = "%ds" % [seconds]
	
	_duration_value.text = duration
	
	_slimes_killed_value.text = str(State.slimes_killed)
	_dragons_killed_value.text = str(State.dragons_killed)
	_ghosts_outlived_value.text = str(State.ghosts_outlived)


func _on_main_menu_button_pressed():
	Globals.switch_game_state(Enums.GameState.MAIN_MENU)


func _on_restart_button_pressed():
	Globals.switch_game_state(Enums.GameState.GAME)
