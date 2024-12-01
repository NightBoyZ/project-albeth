extends Node
var time_holder = 0
var newtime = 0
var Dif = ""

var difficulty_scaling: Dictionary = {
"Easy": 1.1,
"Normal": 1.25,
"Hard": 1.4,
"Very Hard": 1.5
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_holder += delta 
	newtime = "%d:%02d" % [floor(time_holder / 60), int(time_holder) % 60]
	if newtime <= "0:05":
		Dif = "Baby Mode" 
		
	elif newtime >= "0:05" and newtime <= "0:10":
		Dif = "Aight" 
		
	elif newtime >= "0:10" and newtime <= "0:15":
		Dif = "Hard nigger" 
		
	elif newtime >= "0:15" and newtime <= "0:20":
		Dif = "IM HARDER" 
	
	elif newtime >= "0:20" and newtime <= "0:30":
		Dif = "SlimeMania" 
	else :
		Dif = "Error"
	pass
