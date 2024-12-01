extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Closes the main window
	#Key Inputs can be added through Project > Project Settings > Input Map
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
	pass
