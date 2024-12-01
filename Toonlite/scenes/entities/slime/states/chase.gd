#Extends state instead of node
extends State
class_name Chase

@export var enemy: CharacterBody3D

var nav_time: float
var player: CharacterBody3D

var attack_cooldown: float
var direction: Vector3
var new_velocity: Vector3
var move_dir: Vector3
var idle_time: float
var coyote_time: float
var max_splat: int = 1 #fixed

#Called when state firstly transitioned
func on_state_entry():
	coyote_time = 0
	player = enemy.target_player
		
func physics_update(delta: float):
	#updates current position from player
	nav_time += delta
	
	if nav_time >= enemy.navigation_interval:
		direction = (player.global_position + Vector3(randi_range(-2, 2), 0, randi_range(-2, 2))) - enemy.global_position
		new_velocity = direction.normalized() * enemy.speed
		nav_time = 0
	
	if enemy:
		#Updates direction if on ground
		idle_time -= delta
		attack_cooldown -= delta if attack_cooldown >= 0 else 0
		if direction.length() <= 40 and enemy.is_on_floor():
			if direction.length() >= 10 and idle_time < 0:
				idle_time = randi_range(enemy.min_idle_time / 2, enemy.max_idle_time / 2)
								
				enemy.velocity.y = enemy.bounce_strength * randf_range(0.5, 1)
				enemy.velocity.x = new_velocity.x
				enemy.velocity.z = new_velocity.z
				enemy.animation.play("launch", enemy.bounce_strength * 0.1)
				enemy.spawn_particles("splash", 0)
				
				enemy.spawn_goo(2) if max_splat > 0 else null
				max_splat -= 1
				
			elif direction.length() <= 10:
				enemy.velocity.x = new_velocity.x / 3
				enemy.velocity.z = new_velocity.z / 3
				
				if enemy.name != "ShockSlime":
					#enemy.velocity.y = enemy.bounce_strength * randf_range(0.1, 0.3)
					pass
				
				#enemy.spawn_particles("splash", 0)
				enemy.spawn_goo(2) if max_splat > 0 else null
				max_splat -= 1
				
		elif direction.length() <= 12 and !enemy.is_on_floor():
			enemy.velocity.y -= enemy.gravity * delta
			enemy.velocity = lerp(enemy.velocity, Vector3(0, enemy.velocity.y, 0), 0.05)
			enemy.animation.play("bounce", enemy.bounce_strength * 0.1)
			max_splat = 1
				
		#Transition to Patrolling state
		else:
			Transition.emit(self, "Patrol")

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("players") and attack_cooldown <= 0:
		body.take_damage(randi_range(enemy.attack_power/enemy.stat_scaling, enemy.attack_power * enemy.stat_scaling), false)
		body.take_knockback(enemy.knockback_power, enemy.global_position)
		
		#slimes back off slightly after attacking
		enemy.velocity.y = enemy.bounce_strength * randf_range(0.3, 0.5)
		enemy.velocity.x = randf_range(-1, 1) * enemy.speed
		enemy.velocity.z = randf_range(-1, 1) * enemy.speed
		attack_cooldown = enemy.attack_cooldown 

func _on_aoe_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		body.take_damage(randi_range(enemy.attack_power/enemy.stat_scaling, enemy.attack_power * enemy.stat_scaling), false)
