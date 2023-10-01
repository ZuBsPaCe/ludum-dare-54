extends CanvasLayer

@onready var tutorial1 := $Root/Tutorial1
@onready var tutorial2 := $Root/Tutorial2
@onready var tutorial3 := $Root/Tutorial3
@onready var tutorial4 := $Root/Tutorial4
@onready var tutorial5 := $Root/Tutorial5


func setup(tutorial_level: int) -> void:
	var tutorials := [
		tutorial1,
		tutorial2,
		tutorial3,
		tutorial4,
		tutorial5]
	
	for tutorial in tutorials:
		tutorial.visible = false
	
	tutorials[tutorial_level].visible = true
