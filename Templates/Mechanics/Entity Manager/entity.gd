extends CharacterBody3D

var entity_manager = null

func _ready():
	entity_manager = get_tree().root.get_node("Path/To/EntityManager")
	entity_manager.register_entity(self)

func physics_process_custom(delta):
	# Custom physics processing logic for each entity
	velocity = Vector3(0, 0, -1) * 5  # Example movement logic
	move_and_slide()
