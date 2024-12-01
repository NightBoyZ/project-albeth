extends CharacterBody3D

var detected : bool
var speed : float
var run_toggle : bool
var has_controller
var current_location = Vector3.ZERO
var location_to_player = Vector3.ZERO
var new_velocity = Vector3.ZERO
var on_air: bool
var entity_manager = null

@export_group("AI Parameters")
@export var behavior : int = 0
@export var can_act : bool = false
@export var can_jump : bool = false

@export_group("Movement Variables")
#1.0 = 10km
@export var forward_speed : float = 6.0
@export var jump_amount : int = 1
@export var bounce_strength : float = 6.0
@export var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") / 1.5

@export_group("Combat Modifiers")
@export var max_health: int = 100
@export var health: int = 100
@export var stat_scaling: int = 3
@export var attack_cooldown: int = 5
@export var attack_power: int = 1
@export var bullet_speed : float = 20
@export var knockback_multiplier: float = 5.0
@export var projectile: int = 0

@export_group("SFX Settings")
@export var sounds: Array = []

@export_group("VFX Settings")
@export var particles: Dictionary = {
"damage": preload("res://scenes/vfx/environment/damage_indicator.tscn")
}

@onready var enemy_model: Node3D = $Mesh/Armature
@onready var health_bar: Node3D = $HealthBar
@onready var health_timer: Timer = $HealthBar/VisibilityTimer
#@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $CollisionShape3D/NavigationAgent3D

var _jump_amount: int

func _ready():
	entity_manager = get_tree().root.get_node("GameManager/EntityManager")
	#Initializes Health Indicator
	health_bar.text = str(health)
	
	randomize()
	speed = forward_speed
	_jump_amount += jump_amount

func _process(delta):
	pass
	
func _physics_process(delta):
	#get current location
	current_location = global_transform.origin
	#Get position to player(for knockback)
	location_to_player = navigation_agent.get_next_path_position()
	
	#Gravity
	velocity.y -= gravity * delta
		
	#stops the dummy from moving over time
	velocity = lerp(velocity, Vector3(0, velocity.y, 0), 0.1)
		
	move_and_slide()
	update_anim(delta)
	
func update_anim(delta):
	pass

func update_target_location(target_location):
	navigation_agent.target_position = target_location

func spawn_particles(particle_type: String, damage: int):
	var spawn = particles[particle_type].instantiate()
	spawn.position = position

	#to access child nodes of instantiated nodes, you have to contain it twice
	var label = spawn.get_node("DamageIndicator")
	label.text = str(damage)
	add_sibling(spawn) #Adds particles(offset from the enemy as sibling)
	
func take_damage(damage: int):
	health_bar.visible = true
	health_timer.start()
	health -= damage
	if health <= 0:
		health = max_health
		#entity_manager.total_killed += 10
		
	spawn_particles("damage", damage)
	#Updates Health Indicator
	health_bar.text = str(health)

func take_knockback(knockback_pwr, origin):
	velocity += (global_position - origin).normalized() * (knockback_pwr * knockback_multiplier)
	velocity.y = knockback_pwr / 2
	
func dead():
	print(str(self) + "died!")
	get_parent().entities.erase(self)
	spawn_particles("dead", 0)
	queue_free()

func heal(amount):
	pass
	
func _on_hitbox_body_entered(body):
	if body.is_in_group("players") and !is_on_floor() and can_act:
		body.take_damage(randi_range(attack_power/stat_scaling, attack_power*stat_scaling))
	await get_tree().create_timer(attack_cooldown).timeout
	pass # Replace with function body.
	
func _on_visibility_timer_timeout():
	health_bar.visible = false
	pass # Replace with function body.
	
	
