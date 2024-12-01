extends State
class_name PlayerJump

#Export works here because it is the child of Player, which means @onready isn't necessary
@export var player: CharacterBody3D
var move_dir: Vector3
var idle_time: float
var coyote_time: float

#Called when state firstly transitioned
func on_state_entry():
	print("Player is Jumping")
	player._jump_amount = player.jump_amount
	if player._jump_amount > 0 and player.jumping:
		player._jump_amount -= 1
		player.velocity.y = player.jump_strength

func physics_update(delta: float):
	if player:
		player.animation_tree.set("parameters/attack_blend/blend_amount", 0)
		player.animation_tree.set("parameters/AttackState/transition_request", "BasicMelee")
		player.animation_tree.set("parameters/AirOrGround/transition_request", "on_air")
		player.velocity.y -= player.gravity * delta
		#Calculates speed with inbuilt interpolation
		player.velocity.x = move_toward(player.velocity.x, player.direction.x * player.speed, delta * player.damping_value)
		player.velocity.z = move_toward(player.velocity.z, player.direction.z * player.speed, delta * player.damping_value)
		
		if player._jump_amount > 0 and player.jumping:
			player.velocity.y = player.jump_strength
			
		elif player.is_on_floor() or player.collision.disabled:
			player.animation_tree.set("parameters/AirOrGround/transition_request", "on_ground")
			print("Transition to Idle")
			Transition.emit(self, "Idle")
			
