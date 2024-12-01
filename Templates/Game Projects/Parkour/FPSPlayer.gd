extends CharacterBody3D

@export_group("Player Properties")
@export var speed: float = 6.0
@export var run_speed: float = 12.0
@export var jump_velocity: float = 4.5
@export var friction: float = 0.95
@export var air_drag: float = 1.0
@export var damping_value: int = 30

var direction = Vector3.ZERO
var coyote_time: float = 0.2
var grappling = false
var contact_point

#The datatypes after the colons are one method of static typing. 
#It is one of the good practices to get used to.
@export_group("Camera Properties")
@export var camera_fov: float = 90
@export var camera_distance: float = 0

@export var grappling_hook: RayCast3D
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
		camera_pitch.rotate_x(-event.relative.y * 0.005)
		#prevents the camera's rotation from unlimited scrolling
		camera_pitch.rotation.x = clamp(camera_pitch.rotation.x, -PI/2.0, PI/2.0)

func _physics_process(delta):
	if position.y <= -10:
		position = Vector3(0,2,0) 
	
	if Input.is_action_just_pressed("right_click") and grappling_hook.is_colliding():
		velocity *= 0
		contact_point = grappling_hook.get_collision_point()
		grappling = true
	elif Input.is_action_just_released("right_click"):
		grappling = false
			
	#if direction is present and not grappling
	velocity.x = move_toward(velocity.x, direction.x * speed, delta * damping_value)
	velocity.z = move_toward(velocity.z, direction.z * speed, delta * damping_value)
	
	if grappling:
		velocity = lerp(velocity, (contact_point - global_position).normalized() * (speed * 10), delta * damping_value)
	elif !direction and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction)
		velocity.z = move_toward(velocity.z, 0, friction)
		coyote_time = 0.2
	elif !is_on_floor():
		velocity.x *= (1 - air_drag * delta)
		velocity.z *= (1 - air_drag * delta)
		velocity.y -= gravity * delta
		coyote_time -= delta
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or grappling or coyote_time >= 0):
		velocity.y = jump_velocity
		grappling = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# Project > Project Settings > Input Map
	# Alternatively, use Godot's inbuild methods for input handling.
	
	#Defines x and z(horizontal) direction depending on input strength
	direction.x = Input.get_action_strength("d") - Input.get_action_strength("a")
	direction.z = Input.get_action_strength("s") - Input.get_action_strength("w")
	#Adjusts direction depending on the camera's yaw rotation
	direction = direction.rotated(Vector3.UP, camera_yaw.rotation.y)

	move_and_slide()
