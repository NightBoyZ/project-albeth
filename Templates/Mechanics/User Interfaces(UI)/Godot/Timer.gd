extends Label
var time_holder = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_holder += delta
	text = "%d:%02d" % [floor(time_holder / 60), int(time_holder) % 60]
	pass
