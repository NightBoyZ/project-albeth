extends CharacterBody3D

const LERP_VALUE : float = 0.15
const CAMERA_BLEND : float = 0.05
const ANIMATION_BLEND : float = 6.0

var snap_vector : Vector3 = Vector3.DOWN
var saved_pos : Vector3
var action : bool
var speed : float
var run_toggle : bool
var has_controller

@export_group("AI Parameters")
@export var behavior : int = 0
@export var can_act : bool = true
@export var can_jump : bool = false

@export_group("Movement Variables")
@export var walk_speed : float = 2.0
@export var run_speed : float = 5.0
@export var dash_strength : float = 8.0
@export var jump_strength : float = 15.0
@export var jump_amount : int = 1
@export var attack_propel : float = 1.0
@export var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_group("Combat Modifiers")
@export var bullet_speed : float = 20

@export_group("FOV")
@export var change_fov_on_run : bool
@export var normal_fov : float = 90.0
@export var run_fov : float = 120.0
#@export var projectile: PackedScene = preload("res://scenes/test_bullet.tscn")

@onready var enemy_mesh: Node3D = $Mesh
@onready var animation: AnimationTree = $AnimationTree
@onready var particles: CPUParticles3D = $CPUParticles3D
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var _jump_amount: int

func _ready():
	randomize()
	_jump_amount += jump_amount
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func _physics_process(delta):
	var current_location = global_transform.origin
	var next_location = navigation_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * speed
	
	velocity.x = new_velocity.x
	velocity.z = new_velocity.z
	
	print(velocity)
	print(action)
	print(saved_pos)
	print(_jump_amount)
	print(behavior)
	
	if position.y <= -20 or position.y >= 20:
		position = Vector3(randi_range(-20, 20), 20, randi_range(-20, 20))
		
	#var direction : Vector3 = Vector3.ZERO
	#direction.x = randi_range(-1, 1)
	#direction.z = randi_range(-1, 1)
		#
	#if direction:
		#enemy_mesh.rotation.y = lerp_angle(enemy_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
		#saved_pos = Vector3(direction.x, 0, direction.z)
		
	#if behavior == 1:
		#run_toggle = !run_toggle
	#elif behavior == 2:
		#attack()
	#elif behavior == 3:
		#dash(next_location)
	#elif behavior == 4 and can_jump and _jump_amount > 0:
		#_jump_amount -= 1
		#velocity.y = jump_strength
	#elif is_on_floor():
		#_jump_amount = jump_amount
		
#		var spawn = projectile.instantiate()
#		add_child(spawn)
#		spawn.linear_velocity = Vector3(bullet_speed * spring_arm_pivot.rotation.y, 0, bullet_speed * spring_arm_pivot.rotation.y)
#		spawn.reparent(get_parent())
		
	#Movement physics
	if run_toggle:
		speed = run_speed
	elif !run_toggle:
		speed = walk_speed
		
	if action:
		particles.emitting = true
	elif !action:
		particles.emitting = false
		velocity.y -= gravity * delta
		
	move_and_slide()
	update_anim(delta)
	#update_behavior()
	
func update_anim(delta):
	pass
	
#func update_behavior():
	#behavior = randi_range(0, 4)
	#can_act = false
	#await get_tree().create_timer(2).timeout
	#can_act = true
	
func update_target_location(target_location):
	navigation_agent.target_position = target_location
	
func attack():
	action = true
	
	velocity.x = saved_pos.x * attack_propel * walk_speed
	velocity.z = saved_pos.z * attack_propel * walk_speed
	
	action = false
	
func dash(direction):
	action = true
	if direction != Vector3(0,0,0):
		#need logic for dash stop after specific length dashed
		velocity.x *= dash_strength
		velocity.z *= dash_strength
			
	await get_tree().create_timer(0.4).timeout
	action = false
