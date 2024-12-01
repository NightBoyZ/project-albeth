extends Node
class_name State

#Any time you want to switch states, call this signal
signal Transition

func on_state_entry():
	pass
	
func exit_state():
	pass
	
func update_state_behavior(delta: float):
	pass
	
func physics_update(delta: float):
	pass
