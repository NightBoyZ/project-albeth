extends State
class_name PlayerNoClip

#Export works here because it is the child of Player, which means @onready isn't necessary
@export var player: CharacterBody3D
var move_dir: Vector3
var idle_time: float
var coyote_time: float

#Called when state firstly transitioned
func on_state_entry():
	print("Player NoClip Active")

func physics_update(delta: float):
	if player:
		player.animation_tree.set("parameters/attack_blend/blend_amount", 0)
		player.animation_tree.set("parameters/AttackState/transition_request", "BasicMelee")
		player.animation_tree.set("parameters/AirOrGround/transition_request", "on_air")
		player.camera.fov = lerp(player.camera.fov, player.run_fov, delta * player.CAMERA_BLEND)
		player.speed = player.dash_strength
		
		#Calculates speed with inbuilt interpolation
		player.velocity.x = move_toward(player.velocity.x, player.direction.x * player.speed, delta * player.damping_value)
		player.velocity.z = move_toward(player.velocity.z, player.direction.z * player.speed, delta * player.damping_value)
		
		if Input.is_action_pressed("left_click"):
			player.velocity.y = player.dash_strength
		elif Input.is_action_pressed("right_click"):
			player.velocity.y = -player.dash_strength
		else:
			player.velocity.y = move_toward(player.velocity.y, 0, delta * player.damping_value)
		
		if !player.collision.disabled:
			print("Transition to Idle")
			Transition.emit(self, "Idle")
		if player.direction:
			player.last_direction = player.direction
		return
