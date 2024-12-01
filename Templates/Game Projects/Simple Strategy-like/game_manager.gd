extends Node

@export var scores: Array = [0, 0]
@export var spawn_limit: int = 50
@export var player_troops = []
@export var enemy_troops = []
@export var timer: Timer
@onready var mob = preload("res://Game Projects/Simple Strategy-like/enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(spawn_limit):
		print("f")
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_player_score_area_entered(area):
	scores[0] += 1
	area.queue_free()
	pass # Replace with function body.
	
func _on_enemy_score_area_entered(area):
	scores[1] += 1
	area.queue_free()
	pass # Replace with function body.

func _on_timer_timeout():
	var spawn_area = get_viewport().get_visible_rect().size
	var spawn_mobs = mob.instantiate()
	spawn_mobs.position.x = (spawn_area.x) * 100 / 10
	spawn_mobs.position.y = randi_range(spawn_area.y - spawn_area.y, spawn_area.y)
	add_child(spawn_mobs)
	pass # Replace with function body.
