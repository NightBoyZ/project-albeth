extends CharacterBody3D

const LERP_VALUE : float = 0.15
const CAMERA_BLEND : float = 0.1
const ANIMATION_BLEND : float = 6.0

const right_joystick: Dictionary = {
	"look_up": CAMERA_BLEND,
	"look_down": CAMERA_BLEND,
	"look_left": -CAMERA_BLEND,
	"look_right": CAMERA_BLEND,
}

#Unused
enum States {IDLE, JOG, RUNNING, SPRINTING, ATTACKING, JUMPING, AIMING, CASTING}

var snap_vector : Vector3 = Vector3.DOWN #what for?
var direction : Vector3 = Vector3.ZERO
var saved_dir : Vector3
var saved_rotation : float
var speed : float
var is_sprinting : bool
var has_controller

@export_group("Player Parameters")
@export var health : int = 20
@export var max_health : int = 20
@export var strength : int = 2
@export var is_dashing : bool
@export var attacking : bool
@export var camera_dist : float = 1
@export var camera_dist_min : float = 2
@export var camera_dist_max : float = 5
@export var camera_rotate : bool = true

@export_group("Movement Modifiers")
@export var walk_speed : float = 2.5
@export var run_speed : float = 6.3
@export var dash_strength : float = 20.0
@export var dash_length : float = 0.4
@export var jump_strength : float = 5.0
@export var jump_amount : int = 1
@export var attack_propel : float = 1.0
@export var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_group("Combat Modifiers")
@export var bullet_speed : float = 5
@export var projectile: PackedScene = preload("res://scenes/entities/projectiles/laser_beam.tscn")

@export_group("VFX Settings")
@onready var particles: CPUParticles3D = $VFX/CPUParticles3D
@export var test: PackedScene = preload("res://scenes/vfx/player/test.tscn")
@export var trail: PackedScene = preload("res://scenes/vfx/player/trail.tscn")
@onready var animation: AnimationPlayer = $warrior/AnimationPlayer
@onready var animation_tree: AnimationTree = $warrior/AnimationTree
@onready var player_mesh: Node3D = $warrior

@export_group("FOV")
@export var change_fov_on_run : bool
@export var aim_fov : float = 25.0
@export var normal_fov : float = 90.0
@export var run_fov : float = 110.0

@export_group("UI")
@onready var HPBar : ProgressBar = $UI/HPBar

#Yaw is for Y rotation
@onready var camera_yaw: Node3D = $Camera/CameraYaw
#Pitch is for X rotation
@onready var camera_pitch: Node3D = $Camera/CameraYaw/CameraPitch
#The spring arm is used so that the camera wont clip against the floor collision layer
@onready var spring_arm : SpringArm3D = $Camera/CameraYaw/CameraPitch/SpringArm3D
@onready var camera : Camera3D = $Camera/CameraYaw/CameraPitch/SpringArm3D/Camera3D

@onready var spine_rotation: BoneAttachment3D = $Mesh/mannequin/Armature/Skeleton3D/SpineRotation
@onready var aim_raycast : RayCast3D = $Camera/CameraYaw/CameraPitch/Aim
@onready var coyote : Timer = $CoyoteTimer

var _jump_amount: int

func _ready():
	randomize()
	add_to_group("")
	_jump_amount += jump_amount
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#For dynamic camera movement
func _unhandled_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ALT:
			camera_rotate = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			camera_rotate = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			spring_arm.spring_length = lerp(spring_arm.spring_length, camera_dist_min, CAMERA_BLEND)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			spring_arm.spring_length = lerp(spring_arm.spring_length, camera_dist_max, CAMERA_BLEND)
		spring_arm.spring_length = clamp(spring_arm.spring_length, camera_dist_min, camera_dist_max)
	
	if event is InputEventJoypadMotion:
		if camera_rotate:
			print(event.axis)
			#camera_yaw.rotate_y(-event.axis_value * 0.005)
			camera_pitch.rotate_x(-event.axis_value * 0.005)
			camera_pitch.rotation.x = clamp(camera_pitch.rotation.x, -PI/2.5, PI/2.5)
			
	if event is InputEventMouseMotion:
		if camera_rotate:
			camera_yaw.rotate_y(-event.relative.x * 0.005)
			camera_pitch.rotate_x(-event.relative.y * 0.005)
			camera_pitch.rotation.x = clamp(camera_pitch.rotation.x, -PI/2.5, PI/2.5)
			
		#if attacking:
			#spine_rotation.override_pose = true
			#spine_rotation.rotate_x(event.relative.y * 0.005)
			#spine_rotation.rotation.x = clamp(spine_rotation.rotation.x, -PI/2.5, PI/2.5)
		#else:
			#spine_rotation.override_pose = false
		
func _process(delta):
	HPBar.set("value", health)
	#$Tween.interpolate_property(HPBar, "value", HPBar.get("value"), health, 0.2)
	HPBar.set("max_value", max_health)
	print(speed)
	
func _physics_process(delta):
#	print(velocity)
#	print(action)
#	print(saved_dir)
#	print(_jump_amount)
	#print("dashing: ", is_dashing)
	#print("attacking: ", is_attacking)
	
	if health < 0:
		queue_free()
	
	#teleport back to random spot when reached out of y-axis bounds
	if position.y <= -20:
		position = Vector3(randi_range(-20, 20), 20, randi_range(-20, 20))
		
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.z = Input.get_action_strength("down") - Input.get_action_strength("up")
	#checks forward direction depending on camera yaw rotation
	direction = direction.rotated(Vector3.UP, camera_yaw.rotation.y)
	
	#TIL you can use variables like this, makes things more readable i guess. 
	#not really sure about it performance/habit/standard/practice-wise.
	var jumping = Input.is_action_just_pressed("jump") and _jump_amount > 0 
	var aim_press = Input.is_action_just_pressed("right_click")
	var aiming = Input.is_action_pressed("right_click")
	var dashing = Input.is_action_just_pressed("dash") and !is_dashing and is_on_floor()
	var run_toggle = Input.is_action_just_pressed("run")
	
	attacking = Input.is_action_pressed("left_click")
	
	#Behavior codes
	if attacking:
		#var spawn = test.instantiate()
		#add_child(spawn) #Adds particles
		#spawn.global_position = global_position
		#attack()
		pass
		
	if aim_press:
		saved_rotation = player_mesh.rotation.y
		print(player_mesh.rotation.y - deg_to_rad(10.0))
		print(player_mesh.rotation.y + deg_to_rad(10.0))
		print(player_mesh.rotation.y)
		
	if aiming:
		spring_arm.spring_length = lerp(spring_arm.spring_length, 0.8, 0.2)
		camera.h_offset = lerp(camera.h_offset, 0.4, delta * CAMERA_BLEND) 
		camera.v_offset = lerp(camera.v_offset, 0.1, delta * CAMERA_BLEND) 
		camera.fov = lerp(camera.fov, aim_fov, delta * CAMERA_BLEND)
	else:
		camera.h_offset = lerp(camera.h_offset, 0.0, delta * CAMERA_BLEND) 
		camera.v_offset = lerp(camera.v_offset, 0.0, delta * CAMERA_BLEND) 
		
	if is_on_floor():
		#coyote.stop()
		_jump_amount = jump_amount
	elif !is_on_floor():
		pass
		#coyote.start() if coyote.is_stopped() else null
		#print(coyote.time_left)
	
	#Movement physics		
	if jumping:
		_jump_amount -= 1
		velocity.y = jump_strength
	
	#temporary conditions to override movement speeds when dashing.
	if is_dashing:
		speed = dash_strength
		particles.emitting = true
		
	elif !is_dashing:
		if is_sprinting:
			speed = run_speed
		elif !is_sprinting:
			speed = walk_speed

		particles.emitting = false
		
	#only proceeds movement code below when the player has direction input
	if direction:
		saved_dir = Vector3(direction.x, 0, direction.z) #saves horizontal direction
		
		#Toggling movement speed
		if run_toggle:
			is_sprinting = !is_sprinting
		
		if dashing:
			var spawn = trail.instantiate()
			add_child(spawn) #Adds particles
			spawn.global_position = global_position
			dash(direction)
			
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
		
	elif !direction:
		is_sprinting = false

	#Calculates speed depending on state
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	#Camera toggle
	if change_fov_on_run:
		if is_on_floor():
			if is_sprinting:
				camera.fov = lerp(camera.fov, run_fov, delta * CAMERA_BLEND)
			else:
				camera.fov = lerp(camera.fov, normal_fov, delta * CAMERA_BLEND)
		else:
			camera.fov = lerp(camera.fov, normal_fov, delta * CAMERA_BLEND)
	velocity.y -= gravity * delta
	
	move_and_slide()
	update_anim(delta)
	
func update_anim(delta):
	if attacking:
		animation_tree.set("parameters/ActionState/transition_request", "Combat")
	elif !attacking:
		animation_tree.set("parameters/ActionState/transition_request", "Idle")
		
	if is_on_floor():
		animation_tree.set("parameters/Transition_B/transition_request", "on_ground")
		
		if direction:
			animation_tree.set("parameters/ActionState/transition_request", "Move")
			if speed == run_speed:
				animation_tree.set("parameters/Walk_blend/transition_request", 1)
				animation_tree.set("parameters/Walk_blend 2/transition_request", 1)
			else:
				animation_tree.set("parameters/Walk_blend/transition_request", 0)
				animation_tree.set("parameters/Walk_blend 2/transition_request", 0)
	
	elif !is_on_floor():
		animation_tree.set("parameters/Transition_B/transition_request", "on_air")
	pass
	

func take_damage(damage: int):
	health -= damage
	print(str(self) + "Took " + str(damage) + " damage!")

func dash(direction):
	is_dashing = true
	await get_tree().create_timer(dash_length).timeout
	is_dashing = false

