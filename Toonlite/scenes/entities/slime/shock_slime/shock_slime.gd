extends CharacterBody3D

var detected : bool
var speed : float
var cd : float
var run_toggle : bool
var has_controller
var current_location = Vector3.ZERO
var on_air: bool
var knocked: bool
var entity_manager = null
var color: Color
var target_player: CharacterBody3D
var rand_size: float

@export_group("AI Parameters")
@export var behavior : int = 0
@export var can_act : bool = true
@export var can_jump : bool = true
@export var navigation_interval: float = 0.3

@export_group("Movement Variables")
#1.0 = 10km
@export var min_idle_time : float = 1.0
@export var max_idle_time : float = 1.0
@export var forward_speed : float = 18.0
@export var jump_amount : int = 1
@export var bounce_strength : float = 20.0
@export var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") * 3

@export_group("Combat Modifiers")
@export var health: int = 20
@export var stat_scaling: int = 1
@export var score_points: int = 20
@export var experience_points: int = 5
@export var attack_cooldown: float = 3
@export var knockback_power: float = 4.0
@export var knockback_multiplier: float = 1.0
@export var attack_power: int = 4
@export var bullet_speed : float = 20
@export var min_size: float = 0.6
@export var max_size: float = 0.9
@onready var shockwave = preload("res://scenes/entities/slime/shock_slime/shockwave.tscn")
@onready var pulse_bomb = preload("res://scenes/entities/slime/shock_slime/pulse_bomb.tscn")

@export_group("SFX Settings")
@export var sounds: Array = []

@export_group("VFX Settings")
@export var particles: Dictionary = {
"damage": preload("res://scenes/vfx/environment/damage_indicator.tscn"),
"splash": preload("res://scenes/vfx/slime/lowres_splash.tscn"), 
"dead": preload("res://scenes/vfx/slime/dead.tscn")
}

@onready var mesh: Node3D = $Mesh
@onready var state_machine: Node = $StateMachine
@onready var hitbox_area: Node3D = $Hitbox/Area
@onready var enemy_model: Node3D = $Mesh/Model
@onready var health_bar: Node3D = $HealthBar
@onready var collision: CollisionShape3D = $Collision
@onready var health_timer: Timer = $HealthBar/VisibilityTimer
@onready var animation: AnimationPlayer = $AnimationPlayer

var _jump_amount: int

func _ready():
	randomize()
	target_player = get_tree().get_first_node_in_group("players")
	entity_manager = get_tree().root.get_node("GameManager/EntityManager")
	entity_manager.register_capped_entity(self)
	
	#set initials
	rand_size = randf_range(min_size, max_size) * entity_manager.stat_scaling
	score_points *= rand_size
	health *= rand_size 
	scale *= rand_size 
	speed = forward_speed / rand_size 
	attack_power *= rand_size
	attack_cooldown *= (rand_size / 5 * stat_scaling)
	bounce_strength *= (rand_size / 4)
	knockback_power *= (rand_size / 2)
	knockback_multiplier /= (rand_size / 2) #aka knockback weakness
	experience_points *= int(rand_size) 
	
	min_idle_time *= rand_size
	max_idle_time *= rand_size
	
	_jump_amount += jump_amount
	
	color = enemy_model.mesh.material.albedo_color
	enemy_model.mesh.material.albedo_texture.noise.seed = randi_range(0, 9)
	
	#Initializes Health Indicator
	health_bar.text = str(health)
	
func _update_ai(delta: float) -> void:
	#rotates enemy model to the front based on velocity
	mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(velocity.x, velocity.z), 0.1)
	move_and_slide()
	return
		
func spawn_particles(particle_type: String, damage: int):
	var spawn = particles[particle_type].instantiate()
	spawn.position = position
	spawn.scale *= rand_size
	if particle_type != "damage":
		spawn.draw_pass_1.material.albedo_color = enemy_model.mesh.material.albedo_color
	else:
		#to access child nodes of instantiated nodes, you have to contain it twice
		var label = spawn.get_node("DamageIndicator")
		label.text = str(damage)
	add_sibling(spawn) #Adds particles(offset from the enemy as sibling)
	return
	
func spawn_goo(puddle_size: int):
	var spawn = shockwave.instantiate()
	spawn.position = position
	spawn.attack_power = attack_power
	spawn.stat_scaling = attack_power
	add_sibling(spawn)
	return
	
func take_damage(damage: int):
	health_bar.visible = true
	health_timer.start()
	health -= damage
	if health <= 0:
		dead()
		
	spawn_particles("damage", damage)
	#Updates Health Indicator
	health_bar.text = str(health)
	return
	
func take_knockback(knockback_pwr: int, origin: Vector3):
	velocity += (global_position - origin).normalized() * (knockback_pwr * knockback_multiplier)
	velocity.y = knockback_pwr
	return
	
func dead():
	Score.score_total += score_points
	spawn_particles("dead", 0)
	target_player.get_experience(experience_points) #gives exp to player
	entity_manager = get_tree().root.get_node("GameManager/EntityManager")
	entity_manager.total_killed += 1
	entity_manager.erase_capped_entity(self)
	return
	
func _on_visibility_timer_timeout():
	health_bar.visible = false
	return # Replace with function body.
	
