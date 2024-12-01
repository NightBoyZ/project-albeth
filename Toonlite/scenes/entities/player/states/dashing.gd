extends State
class_name PlayerDash

#Export works here because it is the child of Player, which means @onready isn't necessary
@export var player: CharacterBody3D
var move_dir: Vector3
var idle_time: float
var coyote_time: float
var dash_duration

#Called when state firstly transitioned
func on_state_entry():
	print("Player is Dashing")
	player._dash_cooldown = player.dash_cooldown
	dash_duration = player.dash_duration
	player.stamina -= 1
	player.update_ui()

func physics_update(delta: float):
	if player:
		dash_duration -= delta
		if dash_duration > 0:
			player.animation_tree.set("parameters/MovementState/transition_request", "dashing")
			player.iframe = player.max_iframe
			player.speed = player.dash_strength
		
			player.velocity.x = move_toward(player.velocity.x, player.last_direction.x * player.speed, delta * player.damping_value)
			player.velocity.z = move_toward(player.velocity.z, player.last_direction.z * player.speed, delta * player.damping_value)
			
		elif dash_duration < 0:
			print("Transition to Idle")
			Transition.emit(self, "Idle")
			
		elif player.jumping or !player.is_on_floor():
			print("Transition to Jumping")
			Transition.emit(self, "Jump")
			
		elif player.cyclone_skill and player.stamina >= 2:
			print("Transition to Special Attack")
			Transition.emit(self, "SpecialAttack")
			
