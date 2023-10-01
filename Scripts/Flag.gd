extends StaticBody2D


func _on_area_2d_body_entered(body):
	if body.is_in_group(Globals.GROUP_PLAYER):
		Globals.switch_game_state(Enums.GameState.NEXT_TUTORIAL)
