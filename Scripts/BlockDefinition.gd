class_name BlockDefinition
extends RefCounted


var block_index: int
var up: bool
var rotation_counter: int

func _init(
		p_block_index: int,
		p_up: bool,
		p_rotation_counter: int):
	block_index = p_block_index
	up = p_up
	rotation_counter = p_rotation_counter

