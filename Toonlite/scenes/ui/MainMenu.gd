extends Control

@onready var game_scene: PackedScene = load("res://scenes/levels/test_arena/arena.tscn")
@onready var settings_ui: Control = $Settings
@onready var menus: VBoxContainer = $VBoxContainer
@onready var load_game_button: Button = $VBoxContainer/LoadGame
@export var database: JSON

func _ready() -> void:
	#scale *= 0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.5)
	menus.position = Vector2(444,280)
	$Highscore.position.x = 444

func _on_start_game_toggled(toggled_on):
	#holds scene to instantiate
	get_tree().change_scene_to_packed(game_scene)

func _on_load_game_toggled(toggled_on):
	load_game_button.text = "Not Implemented :("
	pass # Replace with function body.

func _on_settings_toggled(toggled_on):
	settings_ui.visible = !settings_ui.visible
	if toggled_on:
		menus.position = Vector2(704,280)
		$Highscore.position.x = 704
	else:
		menus.position = Vector2(504,280)
		$Highscore.position.x = 444

func _on_quit_toggled(toggled_on):
	get_tree().quit()
