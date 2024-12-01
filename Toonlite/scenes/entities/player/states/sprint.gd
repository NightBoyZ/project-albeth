extends State
class_name PlayerSprint

#Export works here because it is the child of Player, which means @onready isn't necessary
@export var player: CharacterBody3D
var move_dir: Vector3
var idle_time: float
var coyote_time: float

#Called when state firstly transitioned
func on_state_entry():
	print("Player is Sprinting")

func physics_update(delta: float):
	if player:
		player.animation_tree.set("parameters/MovementState/transition_request", "walking")
		player.animation_tree.set("parameters/WalkState/transition_request", "sprinting")
		player.camera.fov = lerp(player.camera.fov, player.run_fov, delta * player.CAMERA_BLEND)
		player.speed = player.run_speed
		
		#Calculates speed with inbuilt interpolation
		player.velocity.x = move_toward(player.velocity.x, player.direction.x * player.speed, delta * player.damping_value)
		player.velocity.z = move_toward(player.velocity.z, player.direction.z * player.speed, delta * player.damping_value)
		
		if player.run_toggle:
			print("Transition to Jog")
			Transition.emit(self, "Jog")
		
		elif player.attacking:
			print("Transition to Attacking")
			Transition.emit(self, "BasicAttack")
		
		elif player.cyclone_skill and player.stamina >= 2:
			print("Transition to Special Attack")
			Transition.emit(self, "SpecialAttack")
			
		elif player.dashing:
			print("Transition to Dashing")
			Transition.emit(self, "Dashing")
			
		elif player.jumping or !player.is_on_floor():
			print("Transition to Jumping")
			Transition.emit(self, "Jump")
			
		if !player.direction:
			print("Transition to Idle")
			Transition.emit(self, "Idle")
		if player.direction:
			player.last_direction = player.direction
		return
