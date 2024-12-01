extends Node


##These are functions (In-built)
# Called when the node enters the scene tree for the first time.
func _ready():
	##Calling custom functions
	your_function()
	your_function_2("User")
	your_function_3()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
##These are also functions (Custom)
##Valid functions
func your_function():
	print("Hello world!")
	
func your_function_2(argument: String):
	print("Hello, " + argument + "!")

func your_function_3():
	pass
	
##Invalid functions
#func your_function():
	#print("Hello world!")
	#
#func your_function():
	#print("Hello!")
	#
#func your_function_2(argument: String):
	#print("Hello," + argument + "!")
#
#func your_function_3():
