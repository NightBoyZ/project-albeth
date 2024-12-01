extends Control

@export var game_manager: Node3D
@onready var menu_list = $MenuList
@onready var vignette = $Vignette
@onready var settings = $Settings
@onready var settings_panel = $Settings/Panel
@onready var main_menu_scene: PackedScene = load("res://title_screen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	settings_panel.visible = false
	pass # Replace with function body.

func _on_resume_button_toggled(toggled_on: bool) -> void:
	game_manager.toggle()
	
func _on_settings_button_toggled(toggled_on: bool) -> void:
	settings.visible = toggled_on
	
func _on_main_menu_button_toggled(toggled_on: bool) -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
	
func _on_quit_button_toggled(toggled_on: bool) -> void:
	get_tree().quit()
