extends Node3D

@export_group("Combat Modifiers")
@export var health: int = 100
@export var stat_scaling: int = 3
@export var attack_cooldown: int = 5
@export var knockback_multiplier: float = 5.0
@export var attack_power: int = 1
@export var bullet_speed : float = 20
@export var despawn_time: int = 1
@export var projectile: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = scale * 0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3(1.2,1.2,1.2), 0.1)
	tween.tween_property(self, "scale", Vector3.ONE, 0.2)
	pass # Replace with function body.
	
func _on_hitbox_body_entered(body):
	#Deals damage then removes projectile
	if body.is_in_group("players"):
		body.take_damage(randi_range(attack_power/stat_scaling, attack_power*stat_scaling))
	pass # Replace with function body.

func _on_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.1)
	await tween.finished
	queue_free()
	
	
