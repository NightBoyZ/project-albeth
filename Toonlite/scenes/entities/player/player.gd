#This player script utilises node state machines
#Used to calculate external physics and stats changes like debuffs and so on
extends CharacterBody3D

@export var damping_value : float = 50
@export var CAMERA_BLEND : float = 3.0
@export var ANIMATION_BLEND : float = 6.0

#cache variables
var dt
var jumping
var flying
var aiming
var dashing
var run_toggle
var attacking
var cyclone_skill

var _jump_amount: int
var _dash_cooldown: float = 0
var direction : Vector3 = Vector3.ZERO
var last_direction : Vector3
var saved_rotation : float
var glued_time : float
var iframe : float
var speed : float
var using_controller : bool
var coyote: float

#Temporary manager holder
@export var game_manager: Node3D

@export_group("Player Parameters")
@export var player_level: int = 1
@export var stat_scaling: int = 1.2
@export var experience: int = 0
@export var exp_to_next_level: int = 100
@export var exp_scaling: float = 1.5

@export var R_Weapon: BoneAttachment3D
@export var L_Weapon: BoneAttachment3D

@export var bullet_speed : float = 5.0
@export var animation_speed : float = 1.0
@export var attack_speed : float = 3.0
@export var max_attack_speed : float = 10.0

@export var max_health : int = 50
@export var health : int = 50
@export var max_stamina : int = 12
@export var stamina : int = 12
@export var stamina_consumption_rate: float = 0.2
@export var defense : int = 0
@export var regen_amount : int = 1
@export var regen_speed : float = 1.0 #seconds
@export var strength : int = 1
@export var max_iframe : float = 0.25
@export var can_regen: bool = true
@export var can_recover_st: bool = true
@export var camera_rotate : bool = true
@export var can_act : bool = true
@export var strafe : bool = true
@export var frozen : bool = false
@export var glued : bool = false

#Temporary buff/debuff holder
@export var status_effects : Dictionary = {
"Flaming": 2,
"Frozen": 2,
"Paralysis": 2}

@export_group("Movement Modifiers")
@export var air_drag: float = 2.0
@export var coyote_time: float = 0.2 #basically free time to jump before you can free fall
@export var friction : float = 1
@export var walk_speed : float = 5.5
@export var run_speed : float = 9.3
@export var dash_strength : float = 16.0
@export var dash_duration : float = 0.5
@export var dash_cooldown : float = 1
@export var jump_strength : float = 5.0
@export var jump_amount : int = 1
@export var attack_propel : float = 1.0
@export var knockback_multiplier : float = 5
@export var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_group("VFX Settings")
@export var afterimage : PackedScene 
@export var particles: Dictionary = {
"damage": preload("res://scenes/vfx/environment/damage_indicator.tscn"),
"exp": preload("res://scenes/vfx/environment/exp_indicator.tscn"),
"lvl_up": preload("res://scenes/vfx/environment/lvl_indicator.tscn"),
}

@onready var raycast: RayCast3D = $Collision/RayCast3D
@onready var collision : CollisionShape3D = $Collision
@onready var hitbox : Area3D = $Collision/Hitbox
@onready var animation: AnimationPlayer = $Mesh/Toon_base/AnimationPlayer
@onready var animation_tree: AnimationTree = $Mesh/Toon_base/AnimationTree
@onready var player_mesh: Node3D = $Mesh


@export_group("Camera Settings")
@export var change_fov_on_run : bool
@export var aim_fov : float = 25.0
@export var normal_fov : float = 60.0
@export var run_fov : float = 90.0
@export var skill_fov : float = 110.0
@export var camera_dist : float = 7
@export var camera_dist_min : float = 3
@export var camera_dist_max : float = 12

@export_group("UI")
@onready var UI : Control = $UI
@onready var HPBar : ProgressBar = $UI/GeneralUI/HPBar
@onready var HPBarValue : Label = $UI/GeneralUI/HPBar/Value
@onready var STBar : ProgressBar = $UI/GeneralUI/STBar
@onready var STBarValue : Label = $UI/GeneralUI/STBar/Value
@onready var DebugMenu : Control = $UI/GeneralUI/DebugMenu
@onready var ExpBar : ProgressBar = $UI/GeneralUI/ExpBar
@onready var ExpBarValue : Label = $UI/GeneralUI/ExpBar/Value
@onready var ExpLevel : Label = $UI/GeneralUI/ExpBar/Level
@onready var ScoreValue : Label = $UI/GeneralUI/ExpBar/Score

#Yaw is for Y rotation
@onready var camera_yaw: Node3D = $Camera/CameraYaw
#Pitch is for X rotation
@onready var camera_pitch: Node3D = $Camera/CameraYaw/CameraPitch
#The spring arm is used so that the camera wont clip against the floor collision layer
@onready var spring_arm : SpringArm3D = $Camera/CameraYaw/CameraPitch/SpringArm3D
@onready var camera : Camera3D = $Camera/CameraYaw/CameraPitch/SpringArm3D/Camera3D

#Uncategorised
#@onready var weapon_smear: GPUTrail3D = %Weapon/GreenStick/GPUTrail3D
#@onready var weapon_hitbox: Area3D = %Weapon/GreenStick/WeaponHitbox
@onready var regen_time : Timer = $EffectsManager/RegenTimer

func _ready():
	animation_tree.set("parameters/AttackSpeed/scale", attack_speed)
	animation_tree.set("parameters/SkillSpeed/scale", attack_speed)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spring_arm.spring_length = camera_dist
	regen_time.wait_time = regen_speed
	_jump_amount += jump_amount
	
	init_ui()
	randomize()

#For dynamic camera movement
func _unhandled_input(event):
	if event is InputEventKey and can_act:
		if event.keycode == KEY_ALT:
			camera_rotate = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			camera_rotate = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			spring_arm.spring_length = lerp(spring_arm.spring_length, camera_dist_min, CAMERA_BLEND * dt)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			spring_arm.spring_length = lerp(spring_arm.spring_length, camera_dist_max, CAMERA_BLEND * dt)
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
	dt = delta
	_dash_cooldown -= delta if dash_cooldown >= 0 else 0
	glued_time -= delta if glued_time >= 0 else 0
	iframe -= delta if iframe >= 0 else 0
	
	#teleport back when reached below y-axis bounds
	if position.y <= -20:
		position = Vector3(0, 20, 0)
	
	if can_act:
		#TIL you can use variables like this, makes things more readable i guess. 
		#not really sure about it performance/habit/standard/practice-wise.
		jumping = Input.is_action_just_pressed("jump") and (_jump_amount > 0 or coyote > 0)
		flying = Input.is_action_pressed("jump") and (collision.disabled == true)
		aiming = Input.is_action_pressed("right_click")
		dashing = Input.is_action_just_pressed("dash") and stamina > 0 and _dash_cooldown < 0 and is_on_floor()
		run_toggle = Input.is_action_just_pressed("run") and is_on_floor()
		
		attacking = Input.is_action_pressed("left_click")
		cyclone_skill = Input.is_action_pressed("right_click")
		direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction.z = Input.get_action_strength("down") - Input.get_action_strength("up")
		#checks forward direction with added value depending on camera yaw
		direction = direction.rotated(Vector3.UP, camera_yaw.rotation.y)
			
		#rotates player to front based velocity
		#player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), delta * damping_value)
		#rotates player to front based direction
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(last_direction.x, last_direction.z), delta * damping_value)
		
		if is_on_floor():
			coyote = coyote_time 
			
		elif !is_on_floor():
			coyote -= delta
			velocity.x *= (1 - air_drag * delta)
			velocity.z *= (1 - air_drag * delta)
			
		#Checks for goo
		if glued_time < 0:
			animation_tree.set("parameters/animation_speed/scale", animation_speed)
			friction = lerp(friction, 1.0, delta)
			frozen = false
			
		if raycast.is_colliding():
			stepped_goo()
				
		move_and_slide()
		status_effect_update(delta)
		
	else:
		direction = Vector3.ZERO

func stepped_goo():
	var collider = raycast.get_collider()
	#    v checks if collider is not null
	if collider and collider.is_in_group("goo"):
		glued_time = 0.2
		if collider.is_sticky:
			speed /= 1.01
		elif collider.is_slippery:
			friction = 0.1
	else:
		return
		
func get_experience(exp: int):
	spawn_particles("exp", exp)
	experience += exp
	
	if experience >= exp_to_next_level:
		experience -= exp_to_next_level
		level_up()
		
	update_ui()
	
func level_up():
	spawn_particles("lvl_up", 0)
	player_level += 1
	attack_speed *= stat_scaling if attack_speed <= max_attack_speed else 1
	max_health += player_level * (stat_scaling)
	max_stamina += player_level * (stat_scaling)
	strength += player_level * (stat_scaling)
	exp_to_next_level *= exp_scaling
	
	#too broken
	#regen_amount += player_level
	#regen_speed /= player_level * (stat_scaling) 
	#defense += player_level * (stat_scaling)
	
	animation_tree.set("parameters/AttackSpeed/scale", attack_speed)
	animation_tree.set("parameters/SkillSpeed/scale", attack_speed)
	
	health = max_health
	stamina = max_stamina
	
	HPBar.set("max_value", max_health)
	STBar.set("max_value", max_stamina)
	ExpBar.set("max_value", exp_to_next_level)
	init_ui()
	return
	
#used for future buff/debuff holder
func status_effect_update(delta):
	#time += delta
	#print(fmod(time, regen_amount))
	return

func take_damage(damage: int, is_debuff: bool):
	if iframe < 0 and !game_manager.game_failed:
		iframe = max_iframe
		Engine.time_scale = 0.1
		$UI/HurtVignette/VigAnim.play("Hurt")
		health -= damage * (100 / (100 + defense))
		spawn_particles("damage", damage)
		update_ui()
		
		var hitlag = get_tree().create_tween()
		hitlag.tween_property(Engine, "time_scale", 1.0, 0.2)
		
		if health <= 0:
			animation_tree.set("parameters/SkillSpeed/scale", attack_speed)
			take_knockback(20, -last_direction)
			can_regen = false
			can_act = false
			print("player dead")
			game_manager.game_failed = true
	else:
		return
	
func take_knockback(knockback_pwr: int, origin: Vector3):
	velocity += (global_position - origin).normalized() * (knockback_pwr * knockback_multiplier)
	velocity.y = knockback_pwr
	#velocity.y = velocity.y #to make the player immune to be knocked up high
	last_direction = velocity.normalized()
	return

#might need a better workaround soon
func spawn_particles(particle_type: String, value: int):
	var spawn = particles[particle_type].instantiate()
	spawn.position = position
	if particle_type == "damage":
		#to access child nodes of instantiated nodes, you have to contain it twice
		var label = spawn.get_node("DamageIndicator")
		label.text = str(value)
		#add_child(spawn) #Adds particles as child (follows player)
		
	elif particle_type == "exp":
		var label = spawn.get_node("ExpIndicator")
		label.text = "+EXP" + str(value)
		
	add_sibling(spawn) #Adds particles as seperate scene
	return

#Ui updating logic might need some changes
func init_ui():
	HPBar.set("value", health)
	HPBar.set("max_value", max_health)
	HPBarValue.set("text", str(health) + "/" + str(max_health))
	
	STBar.set("value", stamina)
	STBar.set("max_value", max_stamina)
	STBarValue.set("text", str(stamina) + "/" + str(max_stamina))
	
	ExpBar.set("value", experience)
	ExpBar.set("max_value", exp_to_next_level)
	ExpBarValue.set("text", str(experience) + "/" + str(exp_to_next_level))
	ExpLevel.set("text", "Level " + str(player_level))
	
	return
	
func update_ui():
	HPBarValue.set("text", str(health) + "/" + str(max_health))
	STBarValue.set("text", str(stamina) + "/" + str(max_stamina))
	ExpBarValue.set("text", str(experience) + "/" + str(exp_to_next_level))
	ScoreValue.set("text", "%06d" % Score.score_total)
	
	var ui_tween = get_tree().create_tween()
	ui_tween.tween_property(HPBar, "value", health, 0.1)
	ui_tween.tween_property(STBar, "value", stamina, 0.1)
	ui_tween.tween_property(ExpBar, "value", experience, 0.1)
	
	return
	
func no_clip(toggle):
	collision.disabled = toggle
	return
	
func hitbox_toggle(toggle):
	hitbox.monitoring = toggle
	hitbox.monitorable = toggle
	return
	
func update_stats(stat_name: String, amount):
	print(amount)
	return 
	
#temporary regen timer
func _on_regen_timer_timeout():
	if health < max_health and can_regen:
		health += regen_amount 
	if stamina < max_stamina and can_recover_st:
		stamina += 1
		
	update_ui()
	return
