extends CharacterBody2D
@export var speed = 150.0
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta):
	var next_pos = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(next_pos) * speed
	

	move_and_slide()
