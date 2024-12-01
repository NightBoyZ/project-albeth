extends Control

func _on_volume_value_changed(value):
	return

func _on_check_box_toggled(toggled_on:bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master") ,toggled_on)
	return

func _on_resolutions_item_selected(index):
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600,900))
		2:
			DisplayServer.window_set_size(Vector2i(1280,720))
	return
