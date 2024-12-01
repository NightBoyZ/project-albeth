#Extends state instead of node
extends State
class_name Patrol

@export var enemy: CharacterBody3D
var player: CharacterBody3D
var idle_time: float
var direction: Vector3

#Called when state firstly transitioned
func on_state_entry():
	player = enemy.target_player
	
func physics_update(delta: float):
	if enemy:
		#Updates direction if on ground
		idle_time -= delta
		if enemy.is_on_floor():
			direction = player.global_position - enemy.global_position
			enemy.velocity = lerp(enemy.velocity, Vector3(0, enemy.velocity.y, 0), 0.05)
			if idle_time < 0:
				idle_time = randi_range(enemy.min_idle_time, enemy.max_idle_time)
								
				enemy.velocity.y = enemy.bounce_strength * randf_range(0.3, 1.5)
				enemy.velocity.x = randf_range(-1, 1) * enemy.speed / 2
				enemy.velocity.z = randf_range(-1, 1) * enemy.speed / 2
				
				enemy.spawn_particles("splash", 0)
				enemy.animation.play("launch", enemy.bounce_strength * 0.1)
				enemy.spawn_goo(1)
				
		elif !enemy.is_on_floor():
			enemy.velocity.y -= enemy.gravity * delta
				
		if direction.length() <= 30:
			Transition.emit(self, "Chase")
