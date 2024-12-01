extends Control

@onready var main_menu_scene: PackedScene = load("res://title_screen.tscn")

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
	pass # Replace with function body.
