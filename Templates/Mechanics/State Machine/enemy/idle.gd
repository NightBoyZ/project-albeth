#Extends state instead of node
extends State
class_name EnemyIdle

@export var enemy: CharacterBody2D
@export var speed: int = 10

var move_dir: Vector2
var wander_time: float

# Called when the node enters the scene tree for the first time.
func wander():
	move_dir = Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)

func on_state_entry():
	wander()
	
func update_state_behavior(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		wander()
		
func physics_update(delta: float):
	if enemy:
		enemy.velocity = move_dir * speed
