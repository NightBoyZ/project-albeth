extends Node2D

var dt = 0
var stuff: int = 0
@onready var rows = [[$Row1, $Row2, $Row3]]

func _process(delta):
	for x in rows:
		for y in x:
			print(get_children())
			
