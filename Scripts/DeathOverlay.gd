extends CanvasLayer


func _on_main_menu_button_pressed():
	Globals.switch_game_state(Enums.GameState.MAIN_MENU)


func _on_restart_button_pressed():
	Globals.switch_game_state(Enums.GameState.GAME)
