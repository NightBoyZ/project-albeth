extends Node
#class_name Difficulty

var stat_scaling: float = 2
var difficulty_name = ["Easy", "Normal", "Hard", "Very Hard"]
var current_difficulty: String

func _ready():
	current_difficulty = difficulty_name[0]
	
func _process(delta: float) -> void:
	pass
	
	
