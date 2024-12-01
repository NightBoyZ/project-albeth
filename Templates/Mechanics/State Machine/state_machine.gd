extends Node

@export var initial_state : State
var current_state : State
var states: Dictionary = {}

func _ready() -> void:
	#Gets all child of StateMachine and connects it to transition signal
	for child in get_children():
		if child is State:
			# formats name to lowercase for consistency
			states[child.name.to_lower()] = child
			child.Transition.connect(on_child_transition)
		
	#Updates state if initial state is specified
	if initial_state:
		initial_state.on_state_entry()
		current_state = initial_state
			
func _process(delta: float) -> void:
	if current_state:
		current_state.update_state_behavior(delta)
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
		
func on_child_transition(state, new_state_name):
	#gets new state from the states dictionary
	var new_state = states.get(new_state_name.to_lower())
	
	#returns function if the transitioned state is not the current state
	if state != current_state:
		return
	#returns function if new state not available
	if !new_state:
		return
	#exits the current state if the transitioned state is the current state
	if current_state:
		current_state.exit_state()
	
	#Updates state
	new_state.on_state_entry()
	current_state = new_state
		
