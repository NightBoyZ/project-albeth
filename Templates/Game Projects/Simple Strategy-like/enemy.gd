extends CharacterBody2D

@export var Speed: int = 500.0
@export var Damage: int = 2.0
@export var Health: int = 20

func _physics_process(delta):
	velocity.x += -Speed * delta
	move_and_slide()
