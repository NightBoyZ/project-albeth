#This player script utilises on-script state machines
extends CharacterBody3D

@export var LERP_VALUE : float = 0.5
@export var CAMERA_BLEND : float = 0.5
@export var ANIMATION_BLEND : float = 6.0

@export var right_joystick: Dictionary = {
	"look_up": CAMERA_BLEND,
	"look_down": CAMERA_BLEND,
	"look_left": -CAMERA_BLEND,
	"look_right": CAMERA_BLEND,
}

#State management
enum PlayerStates {IDLE, RUNNING, JUMPING, FALLING, GLIDING}
# This variable keeps track of the character's current state.
var state: PlayerStates = PlayerStates.IDLE


var snap_vector : Vector3 = Vector3.DOWN #what for?
var direction : Vector3 = Vector3.ZERO
var saved_dir : Vector3
var saved_rotation : float
var speed : float
var is_sprinting : bool
var has_controller
var time: float

@export_group("Player Parameters")
@export var max_health : int = 20
@export var health : int = 20
@export var max_stamina : int = 5
@export var stamina : int = 5
@export var defense : int = 0
@export var regen_amount : int = 1
@export var regen_speed : float = 1.0 #seconds
@export var strength : int = 25
@export var is_dashing : bool
@export var attacking : bool
@export var camera_dist : float = 5
@export var camera_dist_min : float = 2
@export var camera_dist_max : float = 7
@export var camera_rotate : bool = true
@export var can_act : bool = true
@export var strafe : bool = true
@export var glued : bool = false
#Format will be {EffectName: Duration}
@export var status_effects : Dictionary = {
"Flaming": 2,
"Frozen": 2,
"Paralysis": 2}

@export_group("Movement Modifiers")
@export var walk_speed : float = 5.5
@export var run_speed : float = 12.3
@export var dash_strength : float = 20.0
@export var dash_length : float = 0.4
@export var jump_strength : float = 5.0
@export var jump_amount : int = 1
@export var attack_propel : float = 1.0
@export var knockback_multiplier : float = 3
@export var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_group("Combat Modifiers")
@export var bullet_speed : float = 5.0
@export var animation_speed : float = 1.0
@export var attack_speed : float = 2.0

@export_group("VFX Settings")
@export var afterimage : PackedScene 
@export var particles: Dictionary = {
"damage": preload("res://scenes/vfx/environment/damage_indicator.tscn"),
"trail": preload("res://scenes/vfx/player/trail.tscn"),
}

@onready var weapon_smear: GPUTrail3D = %Weapon/GreenStick/GPUTrail3D
@onready var animation: AnimationPlayer = $Mesh/mannequin/AnimationPlayer
@onready var animation_tree: AnimationTree = $Mesh/mannequin/AnimationTree
@onready var player_mesh: Node3D = $Mesh
@onready var player_bones: Skeleton3D = $Mesh/mannequin/Armature/Skeleton3D
@onready var player_model: MeshInstance3D = $Mesh/mannequin/Armature/Skeleton3D/Ch36

@export_group("FOV")
@export var change_fov_on_run : bool
@export var aim_fov : float = 25.0
@export var normal_fov : float = 70.0
@export var run_fov : float = 110.0

@export_group("UI")
@onready var UI : Control = $UI
@onready var HPBar : ProgressBar = $UI/HPBar
@onready var HPBarValue : Label = $UI/HPBar/Value
@onready var STBar : ProgressBar = $UI/STBar
@onready var STBarValue : Label = $UI/STBar/Value
@onready var DebugMenu : Control = $UI/DebugToggle/DebugMenu
#@onready var label_anim = %LevelUI/UIAnim

#Yaw is for Y rotation
@onready var camera_yaw: Node3D = $Camera/CameraYaw
#Pitch is for X rotation
@onready var camera_pitch: Node3D = $Camera/CameraYaw/CameraPitch
#The spring arm is used so that the camera wont clip against the floor collision layer
@onready var spring_arm : SpringArm3D = $Camera/CameraYaw/CameraPitch/SpringArm3D
@onready var camera : Camera3D = $Camera/CameraYaw/CameraPitch/SpringArm3D/Camera3D

#Uncategorised
@onready var weapon_hitbox: Area3D = %Weapon/GreenStick/WeaponHitbox
@onready var aim_raycast : RayCast3D = $Camera/CameraYaw/CameraPitch/Aim
@onready var regen_time : Timer = $Effects/RegenTimer
@onready var coyote : Timer = $CoyoteTimer

var _jump_amount: int

func _ready():
	#initializes UI
	init_ui()
	spring_arm.spring_length = camera_dist
	randomize()
	_jump_amount += jump_amount
	regen_time.wait_time = regen_speed
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#For dynamic camera movement
func _unhandled_input(event):
	#if event is InputEventKey:
		#if event.keycode == KEY_ALT:
			#camera_rotate = false
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#else:
			#camera_rotate = true
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
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
	
func _physics_process(delta):
	animation_tree.set("parameters/AttackSpeed/scale", attack_speed)
	
	if can_act:
		#teleport back when reached out of y-axis bounds
		if position.y <= -20:
			position = Vector3(0, 20, 0)
			
		direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction.z = Input.get_action_strength("down") - Input.get_action_strength("up")
		#checks forward direction depending on camera yaw rotation
		direction = direction.rotated(Vector3.UP, camera_yaw.rotation.y)
		
		#TIL you can use variables like this, makes things more readable i guess. 
		#not really sure about it performance/habit/standard/practice-wise.
		var jumping = Input.is_action_just_pressed("jump") and _jump_amount > 0 
		var aim_press = Input.is_action_just_pressed("right_click")
		var aiming = Input.is_action_pressed("right_click")
		var dashing = Input.is_action_just_pressed("dash") and !is_dashing and stamina > 0 and is_on_floor()
		var run_toggle = Input.is_action_just_pressed("run") and is_on_floor()
		
		attacking = Input.is_action_pressed("left_click")
		
		#Behavior codes
		if attacking:
			weapon_smear.visible = true
			weapon_hitbox.monitoring = true
			
			#var spawn = test.instantiate()
			#add_child(spawn) #Adds particles
			#spawn.global_position = global_position
			#shoot()
		else:
			weapon_smear.visible = false
			weapon_hitbox.monitoring = false
			pass
			
		if aim_press:
			saved_rotation = player_mesh.rotation.y
			print(player_mesh.rotation.y - deg_to_rad(10.0))
			print(player_mesh.rotation.y + deg_to_rad(10.0))
			print(player_mesh.rotation.y)
			
		if aiming:
			
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
		if !glued:
			if is_dashing:
				#add_ghost()
				speed = dash_strength
				particles.emitting = true
				#dash_trail.visible = true
				
			elif !is_dashing:
				if is_sprinting:
					speed = run_speed
				elif !is_sprinting:
					speed = walk_speed

			particles.emitting = false
			#dash_trail.visible = false
			
		#only proceeds movement code below when the player has direction input
		if direction and is_on_floor():
			strafe = true
			saved_dir = Vector3(direction.x, 0, direction.z) #saves horizontal direction
			
			#Toggling movement speed
			if !glued:
				if run_toggle:
					is_sprinting = !is_sprinting
				if dashing:
					#spawn_particles("trail", 0)
					dash(direction)
			
			#rotates player to the front based on camera position
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
			
			#Calculates speed depending on state
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			
		elif !direction:
			is_sprinting = false
			velocity.x = move_toward(velocity.x, 0, LERP_VALUE)
			velocity.z = move_toward(velocity.z, 0, LERP_VALUE)
		
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
		status_effect_update(delta)
		update_anim(delta)
	
func update_anim(delta):
	if attacking:
		animation_tree.set("parameters/attack_blend/blend_amount", 1)
	elif !attacking:
		animation_tree.set("parameters/attack_blend/blend_amount", 0)
		animation_tree.set("parameters/ComboList/transition_request", "Melee_1")
		
	if is_on_floor():
		animation_tree.set("parameters/AirOrGround/transition_request", "on_ground")
		
		if direction and !is_dashing:
			animation_tree.set("parameters/MovementState/transition_request", "walking")
			if speed == run_speed and !glued:
				animation_tree.set("parameters/WalkState/transition_request", "sprinting")
			else:
				animation_tree.set("parameters/WalkState/transition_request", "jogging")
				
		elif direction and is_dashing and !glued:
			animation_tree.set("parameters/MovementState/transition_request", "dashing")
		else:
			if strafe and !glued:
				animation_tree.set("parameters/MovementState/transition_request", "strafe")
				strafe = false
			
	elif !is_on_floor():
		animation_tree.set("parameters/AirOrGround/transition_request", "on_air")
	pass
	
#Unused afterimage effect(for dashing)
#func add_ghost():
	#var ghost = afterimage.instantiate()
	#ghost.set_property(position, player_mesh.scale, player_model.mesh, player_mesh.rotation) #important
	##ghost.add_child(player_bones)
	#get_tree().current_scene.add_child(ghost)
	
#used for future buff/debuff holder
func status_effect_update(delta):
	#time += delta
	#print(fmod(time, regen_amount))
	pass

func take_damage(damage: int):
	$UI/HurtVignette/VigAnim.play("Hurt")
	health -= damage * (100 / (100 + defense))
	spawn_particles("damage", damage)
	update_ui()
	
func take_knockback(knockback_pwr: int, origin: Vector3):
	velocity += (global_position - origin).normalized() * (knockback_pwr * knockback_multiplier)
	#velocity.y += knockback_pwr / 2

func dash(direction):
	stamina -= 1
	update_ui()
	
	is_dashing = true
	await get_tree().create_timer(dash_length).timeout
	is_dashing = false

func spawn_particles(particle_type: String, damage: int):
	var spawn = particles[particle_type].instantiate()
	spawn.position = position
	if particle_type == "damage":
		#to access child nodes of instantiated nodes, you have to contain it twice
		var label = spawn.get_node("DamageIndicator")
		label.text = str(damage)
	add_sibling(spawn) #Adds particles

#Ui updating logic might need some changes
func init_ui():
	HPBar.set("value", health)
	HPBar.set("max_value", max_health)
	HPBarValue.set("text", str(health) + "/" + str(max_health))
	
	STBar.set("value", stamina)
	STBar.set("max_value", max_stamina)
	STBarValue.set("text", str(stamina) + "/" + str(max_stamina))
	
func update_ui():
	HPBarValue.set("text", str(health) + "/" + str(max_health))
	STBarValue.set("text", str(stamina) + "/" + str(max_stamina))
	var tween = get_tree().create_tween()
	tween.tween_property(HPBar, "value", health, 0.1)
	tween.tween_property(STBar, "value", stamina, 0.1)
	
	#if HPBar.value <= HPBar.max_value:
		#HPBar.border_width_left = 4
	#else:
		#HPBar.border_width_left = 0
	
func heal(amount):
	pass
	
#temporary regen timer
func _on_regen_timer_timeout():
	if health < max_health:
		health += regen_amount 
	if stamina < max_stamina and !is_dashing:
		stamina += 1
	
	update_ui()
	
func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("goo"):
		animation_tree.set("parameters/animation_speed/scale", animation_speed / 2)
		glued = true
		speed = 2

func _on_hitbox_area_exited(area: Area3D) -> void:
	if area.is_in_group("goo"):
		animation_tree.set("parameters/animation_speed/scale", animation_speed)
		glued = false
		
