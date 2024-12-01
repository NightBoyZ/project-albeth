extends CharacterBody3D

var detected : bool
var run_toggle : bool
var current_location = Vector3.ZERO
var next_location = Vector3.ZERO
var new_velocity = Vector3.ZERO
var knocked: bool = false
var entity_manager = null

@export_group("AI Parameters")
@export var behavior : int = 0
@export var can_act : bool = true
@export var can_jump : bool = false

@export_group("Movement Variables")
#1.0 = 10km
@export var forward_speed : float = 10
@export var bounce_amount : int = 5
@export var bounce_strength : float = 2.0
@export var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") 

@export_group("Combat Modifiers")
@export var health: int = 100
@export var stat_scaling: int = 3
@export var attack_cooldown: int = 5
@export var knockback_multiplier: float = 5.0
@export var attack_power: int = 1
@export var bullet_speed : float = 20
@export var despawn_time: int = 1
@export var projectile: int = 0

@export_group("SFX Settings")
@export var sounds: Array = []

@export_group("VFX Settings")
@export var particles: Dictionary = {
"damage": preload("res://scenes/vfx/environment/damage_indicator.tscn")
}

@onready var afterimage = preload("res://scenes/vfx/projectiles/orb.tscn")
@onready var mesh: Node3D = $Mesh
@onready var enemy_model: Node3D = $Mesh/Model
@onready var health_bar: Node3D = $HealthBar
@onready var health_timer: Timer = $HealthBar/VisibilityTimer
@onready var despawn_timer: Timer = $DespawnTimer
@onready var navigation_agent: NavigationAgent3D = $Collision/NavigationAgent3D

var _bounce_amount: int

func _ready():
	randomize()
	#Initializes Health Indicator
	health_bar.text = str(health)
	#set initials
	_bounce_amount += bounce_amount
	velocity.y = (bounce_strength * bounce_amount) * randf_range(0.5, 1.2)
	
func _physics_process(delta):
	if is_on_floor():
		bounce_amount -= 1
		if bounce_amount <= 0:
			queue_free()
		
	if !is_on_floor():
		current_location = global_transform.origin #Sets current position
		next_location = navigation_agent.get_next_path_position() #Get position to player
		#Calculates direction to player through the navigation mesh, then multiplies by the speed
		new_velocity = (next_location - current_location).normalized() * (forward_speed)
		
		velocity = lerp(velocity, Vector3(0, velocity.y, 0), 0.1) if knocked \
		else new_velocity
		#Starts despawn timer when projectile reaches beyond y-limit or ran out of bounces, else, resets timer
		#if position.y <= -20 or position.y >= 20 or knocked or bounce_amount <= 0:
		#despawn_timer.autostart = true
		if position.y <= -20 or position.y >= 20:
			queue_free()
			
	move_and_slide()

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
		dead()
		
	spawn_particles("damage", damage)
	#Updates Health Indicator
	health_bar.text = str(health)
	
func take_knockback(knockback):
	knocked = true
	velocity = (current_location - next_location).normalized() * (knockback * knockback_multiplier)
	velocity.y = knockback / 2
	
func add_ghost():
	var ghost = afterimage.instantiate()
	ghost.position = position
	#ghost.set_property(position, player_mesh.scale, player_model.mesh, player_mesh.rotation) #important
	#ghost.add_child(player_bones)
	add_sibling(ghost)
	
func dead():
	print(str(self) + "died!")
	queue_free()
	#spawn_particles("dead", 0)
	#entity_manager = get_tree().root.get_node("GameManager/EntityManager")
	#entity_manager.total_killed += 1
	#entity_manager.erase_entity(self)
	
func temp_hpbar():
	pass
	
func _on_hitbox_body_entered(body):
	#Deals damage then removes projectile
	if body.is_in_group("players"):
		body.take_damage(randi_range(attack_power/stat_scaling, attack_power*stat_scaling))
		queue_free()
	pass # Replace with function body.
	
func _on_visibility_timer_timeout():
	health_bar.visible = false
	pass # Replace with function body.
	
func _on_despawn_timer_timeout():
	queue_free()
	pass # Replace with function body.
