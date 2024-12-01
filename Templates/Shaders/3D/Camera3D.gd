extends Node3D

@onready var camera: Node3D = $CameraPitch/Camera3D
@onready var camera_pitch: Node3D = $CameraPitch

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.
	
func _unhandled_input(event):
	#scans for mouse motion
	if event.is_action_pressed("esc"):
		get_tree().quit()
		
	if event is InputEventMouseMotion:
		rotate_y(event.relative.x * 0.005)
		camera_pitch.rotate_x(event.relative.y * 0.005)
		#prevents the camera's rotation from unlimited scrolling
		camera_pitch.rotation.x = clamp(camera_pitch.rotation.x, -PI/2.5, PI/2.5)
