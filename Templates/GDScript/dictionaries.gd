extends Node

##To test the codes select the codes below the double hashtags and uncomment it with CTRL+K
##Then drag the script from FileSystem to the GDScriptTest scene root and run with F6.

##valid dictionary
var dict: Dictionary = {
	"one": 1,
	"second": 2,
	"third": 3,
	"four": 4
	}

##invalid dictionary
#var dict: Dictionary = {
	#"one": 1,
	#"one": 2,
	#"third": 3,
	#"four": 4
	#}

func _ready():
	#output and accessing
	print(dict)
	print(dict["one"])
	pass
