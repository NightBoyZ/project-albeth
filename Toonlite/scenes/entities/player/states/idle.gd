extends State
class_name PlayerIdle

#Export works here because it is the child of Player, which means @onready isn't necessary
@export var player: CharacterBody3D
var move_dir: Vector3
var idle_time: float
var coyote_time: float

#Called when state firstly transitioned
func on_state_entry():
	print("Player is Idling")

func physics_update(delta: float):
	if player:
		player.R_Weapon.update_hitbox(false)
		player.L_Weapon.update_hitbox(false)
		player.animation_tree.set("parameters/attack_blend/blend_amount", 0)
		player.animation_tree.set("parameters/AttackState/transition_request", "BasicMelee")
		player.animation_tree.set("parameters/MovementState/transition_request", "idle")
		player.camera.fov = lerp(player.camera.fov, player.normal_fov, delta * player.CAMERA_BLEND)
		player.velocity.x = move_toward(player.velocity.x, 0, player.friction)
		player.velocity.z = move_toward(player.velocity.z, 0, player.friction)
		
		if player.direction != Vector3.ZERO:
			print("Transition to Jog")
			Transition.emit(self, "Jog")
			
		elif player.jumping or !player.is_on_floor() and !player.collision.disabled:
			print("Transition to Jumping")
			Transition.emit(self, "Jump")
		
		elif player.attacking:
			print("Transition to Attacking")
			Transition.emit(self, "BasicAttack")
			
		elif player.cyclone_skill and player.stamina >= 2:
			print("Transition to Special Attack")
			Transition.emit(self, "SpecialAttack")
			
		elif player.collision.disabled:
			print("Transition to NoClip")
			Transition.emit(self, "NoClip")
			
