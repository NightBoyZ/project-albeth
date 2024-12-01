extends Camera3D

func _process(delta: float) -> void:
	position = lerp(position, Vector3(30, 2, -5), 0.01)
	global_rotation_degrees.x = lerpf(global_rotation_degrees.x, 10, 0.01)
	global_rotation_degrees.y = lerpf(global_rotation_degrees.y, 128, 0.01)
	
