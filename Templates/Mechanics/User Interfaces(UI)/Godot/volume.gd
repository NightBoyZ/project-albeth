extends HSlider

@export var bus_name: String
@export var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_value_changed(value: float) -> void:
	# If you're using Godot 3, replace linear_to_db() with linear2db()
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value/80))
