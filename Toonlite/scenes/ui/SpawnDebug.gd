extends VBoxContainer

var entity_manager = null

func _ready():
	entity_manager = get_tree().root.get_node("GameManager/EntityManager")

func _on_lesser_toggled(toggled_on):
	entity_manager.entity_list[0][1] = toggled_on
	grab_focus()

func _on_ice_toggled(toggled_on):
	entity_manager.entity_list[1][1] = toggled_on
	grab_focus()

func _on_fire_toggled(toggled_on):
	entity_manager.entity_list[2][1] = toggled_on
	grab_focus()

func _on_shock_toggled(toggled_on):
	entity_manager.entity_list[3][1] = toggled_on
	grab_focus()

func _on_nature_toggled(toggled_on):
	entity_manager.entity_list[4][1] = toggled_on
	grab_focus()
