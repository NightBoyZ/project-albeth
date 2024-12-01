extends MeshInstance3D

var attack_power: int
var stat_scaling: float

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3(3,1,3), 0.2)
	await tween.finished
	queue_free()

func _on_aoe_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		body.take_damage(randi_range(attack_power/stat_scaling, attack_power * stat_scaling), false)
