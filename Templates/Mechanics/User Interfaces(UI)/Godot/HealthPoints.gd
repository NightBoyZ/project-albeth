extends ProgressBar
@export var health = 50
@export var maxhealth = 150

# Called when the node enters the scene tree for the first time.
@onready var label:Label = $Label
func _ready():
	label.text = str(health) + str("/") + str(maxhealth) 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = health
	max_value = maxhealth
	pass
