extends ProgressBar
@export var mana = 50
@export var maxmana = 100

# Called when the node enters the scene tree for the first time.
@onready var label:Label = $Label
func _ready():
	label.text = str(mana) + str("/") + str(maxmana) 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = mana
	max_value = maxmana
	pass
