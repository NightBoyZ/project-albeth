extends Node

#Short for enumerate
enum {One, Two, Three}
enum Enum{One = 5, Two, Three}
enum Enum2{One = 3, Two, Three}

# Called when the node enters the scene tree for the first time.
func _ready():
	#Accessing and output
	print(One)
	print(Two)
	print(Three)
	print(Enum.One)
	print(Enum2.One)
	pass # Replace with function body.
