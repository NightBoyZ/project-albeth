extends VBoxContainer

@onready var total_exp = $PlayerExp/Value
@export var player: CharacterBody3D

func _on_apply_button_pressed() -> void:
	player.get_experience(int(total_exp.get("text")))
	grab_focus()

func _on_no_clip_toggle_toggled(toggled_on: bool) -> void:
	player.no_clip(toggled_on)
	grab_focus()

func _on_hitbox_toggle_toggled(toggled_on: bool) -> void:
	player.hitbox_toggle(toggled_on)
	grab_focus()
