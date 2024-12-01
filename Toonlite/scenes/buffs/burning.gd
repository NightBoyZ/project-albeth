extends Node3D
class_name Burning

var interval: float = 1.0
var duration: float = 1.0

@onready var e = preload("res://scenes/entities/player/dummy/dummy.tscn")
@export var effect_duration: float = 2.0
@export var effect_interval: float = 0.2
@export var entity: CharacterBody3D

func _ready() -> void:
	duration = effect_duration
	interval = effect_interval
	pass 

# Called every frame. 'delta' is the elapsed duration since the previous frame.
func _physics_process(delta: float) -> void:
	duration -= delta if effect_duration >= 0.0 else 0
	interval -= delta if effect_interval >= 0.0 else 0

	if interval < 0:
		entity.take_damage(1, true)
		interval = effect_interval
	
	if duration < 0:
		queue_free()
