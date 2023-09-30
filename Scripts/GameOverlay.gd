extends CanvasLayer

@export var heart_tex: Texture2D


@onready var _heart_container := $%HeartContainer


func _ready():
	State.health_changed.connect(_on_health_changed)


func _on_MainMenuButton_pressed():
	Globals.switch_game_state(Enums.GameState.MAIN_MENU)


func _on_health_changed(new_health: int):
	while new_health > _heart_container.get_child_count():
		var heart := TextureRect.new()
		heart.texture = heart_tex
		heart.modulate = Globals.heart_color
		_heart_container.add_child(heart)
	
	while new_health < _heart_container.get_child_count():
		var child = _heart_container.get_child( _heart_container.get_child_count() - 1)
		_heart_container.remove_child(child)
		child.queue_free()
