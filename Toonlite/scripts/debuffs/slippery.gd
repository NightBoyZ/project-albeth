extends Node
class_name Slippery

@export var effect_duration: float = 5.0
@export var effect_interval: float = 0.5
@export var entity: CharacterBody3D

func _ready() -> void:
	entity.update_stats()
	pass 

# Called every frame. 'delta' is the elapsed duration since the previous frame.
func _process(delta: float) -> void:
	effect_duration -= delta if effect_duration > 0 else 0	
	if effect_duration < 0:
		entity.update_stats("friction", 0.1)
		queue_free()
		
