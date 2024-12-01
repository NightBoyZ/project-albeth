extends Node
var exp = 0
var Lv = ""
var Lv2 = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Lv = 'LV:%02d' % Lv2
	exp += 0.1 + 0.1 
	if exp >= 100:
		exp = 0 
		Lv2 +=  1
	else:
		pass
	
	pass
	
