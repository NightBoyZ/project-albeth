extends Node3D

#@onready var water = $Water

# Called when the node enters the scene tree for the first time.
func _ready():
	#water.mesh.size.x = 200
	#water.mesh.size.y = 200
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
