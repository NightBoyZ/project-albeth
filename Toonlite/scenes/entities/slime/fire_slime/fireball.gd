extends CharacterBody3D

var direction: Vector3
var entity_manager = null
var damage: int

@export_group("SFX Settings")
@export var sounds: Array = []

func _ready():
	randomize()
	
func _physics_process(delta: float) -> void:
	pass
	
func dead():
	entity_manager.erase_uncapped_entity(self)
	
func _on_hitbox_body_entered(body):
	#Deals damage then removes projectile
	if body.is_in_group("players"):
		body.take_damage(damage)
		dead()
	pass # Replace with function body.
