extends ProgressBar

var hp: int = 10 * Difficulty.difficulty_scaling["Hard"]
var maxhp: int = 20 * Difficulty.difficulty_scaling["Hard"]

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	value = hp 
	max_value = maxhp 
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label.set("text", str(hp) + "/" + str(maxhp))
	pass
