extends State
class_name SpecialAttack

#Export works here because it is the child of Player, which means @onready isn't necessary
@export var player: CharacterBody3D
var stamina_consumption_rate: float = 0
var move_dir: Vector3
var idle_time: float
var coyote_time: float

#Called when state firstly transitioned
func on_state_entry():
	print("Player is using Special Attack")

func physics_update(delta: float):
	if player:
		player.R_Weapon.update_hitbox(true)
		player.L_Weapon.update_hitbox(true)
		player.animation_tree.set("parameters/attack_blend/blend_amount", 0)
		player.animation_tree.set("parameters/AttackState/transition_request", "SkillMelee")
		player.camera.fov = lerp(player.camera.fov, player.skill_fov, delta * player.CAMERA_BLEND)
		player.velocity.x = move_toward(player.velocity.x, player.last_direction.x * player.speed, delta * player.damping_value)
		player.velocity.z = move_toward(player.velocity.z, player.last_direction.z * player.speed, delta * player.damping_value)
		player.speed = player.attack_propel
		player.can_recover_st = false
		stamina_consumption_rate -= delta if stamina_consumption_rate >= 0 else 0
		
		if stamina_consumption_rate <= 0:
			player.stamina -= 1
			stamina_consumption_rate = player.stamina_consumption_rate
			player.update_ui
			
		if player.jumping or !player.is_on_floor():
			print("Transition to Jumping")
			Transition.emit(self, "Jump")
			
		elif !player.cyclone_skill or player.stamina < 0:
			player.can_recover_st = true
			print("Transition to Idle")
			Transition.emit(self, "Idle")
