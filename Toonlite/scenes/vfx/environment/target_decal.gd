extends Decal

@onready var timer : Timer = $Timer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(0.01)
	
func _on_timer_timeout() -> void:
	queue_free()
