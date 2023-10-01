extends CanvasLayer

@export var heart_scene: PackedScene


@onready var _heart_container := $%HeartContainer
@onready var _main_menu_button := $%MainMenuButton

@onready var _rotate_gear := false

func _ready():
	State.health_changed.connect(_on_health_changed)
	

func _process(delta):
	if _rotate_gear:
		_main_menu_button.rotation += delta * PI


func _on_health_changed(new_health: int):
	while new_health > _heart_container.get_child_count():
		var heart := heart_scene.instantiate()
		_heart_container.add_child(heart)
	
	while new_health < _heart_container.get_child_count():
		var child = _heart_container.get_child( _heart_container.get_child_count() - 1)
		_heart_container.remove_child(child)
		child.queue_free()


func _on_main_menu_button_mouse_entered():
	_rotate_gear = true
	State.block_disabled = true


func _on_main_menu_button_mouse_exited():
	_rotate_gear = false
	State.block_disabled = false
	

func _on_main_menu_button_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and !event.is_echo():
		State.block_disabled = false
		Globals.switch_game_state(Enums.GameState.PAUSE)
