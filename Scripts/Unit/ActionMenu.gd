extends GridContainer
class_name ActionMenu

onready var _actions = $Actions


func initialize(weapons: Array) -> void:
	for weapon in weapons:
		_actions.get_popup().add_item(weapon.weapon_name)
