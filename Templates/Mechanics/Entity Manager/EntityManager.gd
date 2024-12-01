extends Node

var entities = []

func _ready():
	# This function runs when the script instance is ready
	print("Entity Manager Ready")

func register_entity(entity):
	entities.append(entity)
	print("Registered entity:", entity.name)

func physics_update_entities(delta):
	for entity in entities:
		entity.physics_process_custom(delta)

func _physics_process(delta):
	physics_update_entities(delta)
