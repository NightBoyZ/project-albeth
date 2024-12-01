extends Node

var variable = 0
@export var export_var = 0
@onready var onready_var = 1
const constant_var = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	print(variable, export_var, onready_var, constant_var)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
