extends MeshInstance3D

@onready var collision = $StaticBody3D/CollisionShape3D
@onready var detect_area = $Area3D/CollisionShape3D
@onready var timer = $SizeTimer
@export var expand_size: float = 6.0
@onready var detect = $Area3D
var mode: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
#	detect_area.shape.radius = expand_size + 1
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if mode:
		position.y = lerp(position.y, expand_size / 2.0, 0.2)
		mesh.size.y = lerp(mesh.size.y, expand_size, 0.2)
		collision.shape.size.y = lerp(collision.shape.size.y, expand_size, 0.2)
	elif !mode:
		position.y = lerp(position.y, 0.0, 0.2)
		mesh.size.y = lerp(mesh.size.y, 1.0, 0.2)
		collision.shape.size.y = lerp(collision.shape.size.y, 1.0, 0.2)
		
#	if mode:
#		position.y = lerp(position.y, expand_size / 2.0, delta / (timer.time_left / 3))
#		mesh.size.y = lerp(mesh.size.y, expand_size, delta / (timer.time_left / 3))
#		collision.shape.size.y = lerp(collision.shape.size.y, expand_size, delta / (timer.time_left / 3))
#	elif !mode:
#		position.y = lerp(position.y, 0.0, delta / (timer.time_left / 4))
#		mesh.size.y = lerp(mesh.size.y, 1.0, delta / timer.time_left)
#		collision.shape.size.y = lerp(collision.shape.size.y, 1.0, delta / timer.time_left)
		

func _on_size_timer_timeout():
#	mode = !mode
#	timer.start(2)
	pass

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		mode = true
	pass # Replace with function body.

func _on_area_3d_body_exited(body):
	if body.name == "Player":
		mode = false
	pass # Replace with function body.
