extends CharacterBody3D

var detected : bool
var speed : float
var run_toggle : bool
var has_controller
var current_location = Vector3.ZERO
var next_location = Vector3.ZERO
var new_velocity = Vector3.ZERO
var entity_manager = null

@export_group("AI Parameters")
@export var behavior : int = 0
@export var can_act : bool = true
@export var can_jump : bool = false

@export_group("Movement Variables")
#1.0 = 10km
@export var walk_speed : float = 0.5
@export var run_speed : float = 1.3
@export var dash_strength : float = 2.0
@export var jump_strength : float = 2.0
@export var jump_amount : int = 1
@export var attack_propel : float = 5.0
@export var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_group("Combat Modifiers")
@export var bullet_speed : float = 20
#@export var projectile: PackedScene = preload("res://scenes/test_bullet.tscn")

@export_group("VFX Settings")

@onready var enemy_mesh: Node3D = $Mesh
@onready var detection_timer: Timer = $DetectionTimer
@onready var animation: AnimationPlayer = $Mesh/zombequin/AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $CollisionShape3D/NavigationAgent3D
@onready var health_bar: Label3D = $HealthBarPivot/Label3D
@onready var health_bar_pivot: Node3D = $HealthBarPivot
@onready var aim: RayCast3D = $RayCast3D

var _jump_amount: int

func _ready():
	randomize()
	_jump_amount += jump_amount
	
	entity_manager = get_tree().root.get_node("GameManager/EntityManager")
	entity_manager.register_entity(self)
	#print(detection_timer.time_left)
	#print(detected)
	#print(saved_pos)
	#print(_jump_amount)
	#print(behavior)
		
func _update_ai(delta):
	#need to adjust to it doesn't calculate every frame, causes performance tank.
	#for now i utilize godot timers to reduce frequency, will update to frame checks later
	#moved to timeout signal & removed if condition(debug paths not visible with this method
	if can_act:
		#Makes health bar UI always facing the player (might cause errors when multiplayer)
		#Changing to SubVIewport method soon
		health_bar_pivot.rotation.y = atan2(velocity.x, velocity.z)
		#Rotates enemy model from the y axis according to player location
		enemy_mesh.rotation.y = lerp_angle(enemy_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
		
		#Does the velocity updates based on the navigation variables
		velocity.x = new_velocity.x
		velocity.z = new_velocity.z
		
		if next_location == Vector3.ZERO:
			#updates current position
			current_location = global_transform.origin
			#Get position to player
			next_location = navigation_agent.get_next_path_position()
			#Calculates direction to player through the navigation mesh, then multiplies by the speed
			new_velocity = (next_location - current_location).normalized() * speed
			
			#multiply by number to increase range
			aim.target_position = (next_location - current_location).normalized() * 2
			#Randomizes timer wait time for more natural movement, won't want every enemy move at the same time.

	#Position updates when too far from set y-axis coords
	if position.y <= -20 or position.y >= 20:
		position = Vector3(randi_range(-20, 20), 2, randi_range(-20, 20))
		
	if aim.is_colliding() and can_act == true:
		attack()

	if run_toggle:
		speed = run_speed
	elif !run_toggle:
		speed = walk_speed
		
	#Constant gravity
	velocity.y -= gravity * delta
	
	#if detected:
		#particles.emitting = true
	#elif !detected:
		#particles.emitting = false
		#velocity.y -= gravity * delta
		
	move_and_slide()
	update_anim(delta)
	
func update_anim(delta):
	animation.play("Chase")

func update_target_location(target_location):
	navigation_agent.target_position = target_location
	
func attack():
	can_act = false
	velocity.x *= attack_propel
	velocity.z *= attack_propel
	await get_tree().create_timer(0.8).timeout	
	can_act = true

func _on_detection_timer_timeout():
	next_location = Vector3.ZERO
	detection_timer.wait_time = randf_range(0.5, 1)
	
func take_damage():
	queue_free()
	
