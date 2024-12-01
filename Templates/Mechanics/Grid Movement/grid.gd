extends Node2D

var tile_size: int = 128
var inputs: Dictionary = {
	"w": Vector2.UP,
	"a": Vector2.LEFT,
	"s": Vector2.DOWN,
	"d": Vector2.RIGHT}
	
@onready var agent = $Icon

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	for direction in inputs.keys():
		if event.is_action_pressed(direction):
			agent.position += inputs[direction] * tile_size
