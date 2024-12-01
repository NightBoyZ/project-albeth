extends StaticBody3D

@export var entity = [preload("res://scenes/entities/slime/lesser_slime.tscn")]
@export var activated: bool = false
@export var spawn_cap: int = 100

@onready var timer: Timer = $Timer

var count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if count < spawn_cap:
		var spawn = entity.pick_random().instantiate()
		add_sibling(spawn)
		spawn.position = position
		spawn.position.y = 5
		count += 1

