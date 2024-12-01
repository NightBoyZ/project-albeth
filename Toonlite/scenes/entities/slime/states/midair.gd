#Unused
extends State
class_name Midair

@export var enemy: CharacterBody3D
var player: CharacterBody3D

var idle_time: float

#Called when state firstly transitioned
func on_state_entry():
	pass
	
func physics_update(delta: float):
	if enemy:
		print("on air")
		enemy.velocity = lerp(enemy.velocity, Vector3(0, enemy.velocity.y, 0), 0.05)
		#Transition to Chase state
		if enemy.is_on_floor():
			Transition.emit(self, "Chase")
