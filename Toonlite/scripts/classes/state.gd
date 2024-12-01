extends Node
class_name State

#Any time you want to switch states, call this signal
signal Transition

func on_state_entry() -> void:
	pass
	
func exit_state() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	pass
	
func update_state_process(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass
