extends MeshInstance3D
 
func _ready():
	ghosting()
 
func set_property(tx_pos, tx_scale, tx_mesh, tx_rot):
	position = tx_pos
	scale = tx_scale
	mesh = tx_mesh
	rotation = tx_rot
 
func ghosting():
	var tween_fade = get_tree().create_tween()
	tween_fade.tween_property(self, "scale", scale * 0, 0.75)
	await tween_fade.finished
 
	queue_free()
