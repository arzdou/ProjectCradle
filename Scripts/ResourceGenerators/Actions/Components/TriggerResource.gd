# This resource is used to check if reactions are activated when actions are 
# performed in the GameBoard 

extends Resource
class_name TriggerResource

enum TRIGGERS {OVERWATCH, BRACE}
@export var trigger_type: TRIGGERS

const brace_action: MiscAction = preload("res://Resources/Actions/brace/brace.tres")

func get_triggered_actions(action: BaseAction, reacting_unit: Unit, acting_unit: Unit) -> Array[BaseAction]:
	match trigger_type:
		TRIGGERS.OVERWATCH:
			return overwatch(action, reacting_unit, acting_unit)
		TRIGGERS.BRACE:
			return brace(action, reacting_unit, acting_unit)
		_:
			return []


# Activated when action is a MoveAction and target unit moves in threat unit from active unit
func overwatch(action: BaseAction, reacting_unit: Unit, acting_unit: Unit) -> Array[BaseAction]:
	var active_threat_weapons: Array[BaseAction] = []
	
	if not action is MoveAction:
		return active_threat_weapons
	
	if reacting_unit == acting_unit:
		return active_threat_weapons
	
	# Threat dict is adictionary where the keys are the weapons and the values are the THREAT modes
	var threat_dict: Dictionary = reacting_unit.get_threat()
	
	# Find which of the threat weapons are in range
	for weapon in threat_dict:
		weapon.range_mode = threat_dict[weapon]
		if weapon.is_in_range(reacting_unit.cell, acting_unit.cell): # Think a way of doing it
			active_threat_weapons.push_back(weapon)
	
	return active_threat_weapons


func brace(action: BaseAction, reacting_unit: Unit, acting_unit: Unit) -> Array[BaseAction]:
	var out: Array[BaseAction] = []
	
	if not action is WeaponAction:
		return out
	
	if reacting_unit == acting_unit:
		return out
	
	if not action.is_in_range(acting_unit.cell, reacting_unit.cell):
		return out
	
	# This will fail since this method has no way of knowing which target has the action
	out.push_back(brace_action)
	return out
