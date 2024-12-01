extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var direction = Vector3.ZERO

#The datatypes after the colons are one method of static typing. 
#It is one of the good practices to get used to.
@export_group("Camera Properties")
@export var camera_fov: float = 90
@export var camera_distance: float = 5.0

@onready var camera: Node3D = $CameraYaw/CameraPitch/CameraSpring/Camera3D
@onready var camera_yaw: Node3D = $CameraYaw
@onready var camera_pitch: Node3D = $CameraYaw/CameraPitch
@onready var camera_spring_arm: Node3D = $CameraYaw/CameraPitch/CameraSpring

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Inbuilt function that runs it's content first when instanced.
func _ready():
	camera_spring_arm.spring_length = camera_distance
	#captures the mouse cursor inside the game window
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#inbuilt method to scan for unhandled input.
func _unhandled_input(event):
	#scans for mouse motion
	if event is InputEventMouseMotion:
		camera_yaw.rotate_y(-event.relative.x * 0.005)
		camera_pitch.rotate_x(event.relative.y * 0.005)
		#prevents the camera's rotation from unlimited scrolling
		camera_pitch.rotation.x = clamp(camera_pitch.rotation.x, -PI/2.5, PI/2.5)

func _physics_process(delta):
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# Project > Project Settings > Input Map
	# Alternatively, use Godot's inbuild methods for input handling.
	
	#Defines x and z(horizontal) direction depending on input strength
	direction.x = Input.get_action_strength("d") - Input.get_action_strength("a")
	direction.z = Input.get_action_strength("s") - Input.get_action_strength("w")
	#Adjusts direction depending on the camera's yaw rotation
	direction = direction.rotated(Vector3.UP, camera_yaw.rotation.y)
	
	#if direction is present
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
