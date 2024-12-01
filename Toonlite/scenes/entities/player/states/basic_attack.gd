extends State
class_name BasicAttack

#Export works here because it is the child of Player, which means @onready isn't necessary
@export var player: CharacterBody3D
var enemy: CharacterBody3D
var move_dir: Vector3
var idle_time: float
var coyote_time: float

#Called when state firstly transitioned
func on_state_entry():
	print("Player is Attacking")

func physics_update(delta: float):
	if player:
		player.R_Weapon.update_hitbox(true)
		player.L_Weapon.update_hitbox(true)
		player.animation_tree.set("parameters/attack_blend/blend_amount", 1)
		player.animation_tree.set("parameters/AttackState/transition_request", "BasicMelee")
		player.velocity.x = move_toward(player.velocity.x, player.last_direction.x * player.speed, delta * player.damping_value)
		player.velocity.z = move_toward(player.velocity.z, player.last_direction.z * player.speed, delta * player.damping_value)
		player.speed = player.attack_propel
			
		if player.jumping or !player.is_on_floor():
			print("Transition to Jumping")
			Transition.emit(self, "Jump")
			
		if !player.attacking:
			print("Transition to Idle")
			Transition.emit(self, "Idle")
