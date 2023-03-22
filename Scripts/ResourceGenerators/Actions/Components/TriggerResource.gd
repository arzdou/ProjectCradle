# This resource is used to check if reactions are activated when actions are 
# performed in the GameBoard 

extends Resource
class_name TriggerResource

enum TRIGGERS {OVERWATCH, BRACE}
@export var trigger_type: TRIGGERS

const brace_action: MiscAction = preload("res://Resources/Actions/brace/brace.tres")

func get_triggered_actions(action_to_react: ResolvedAction, reacting_unit: Unit, acting_unit: Unit) -> Array[BaseAction]:
	match trigger_type:
		TRIGGERS.OVERWATCH:
			return overwatch(action_to_react, reacting_unit, acting_unit)
		TRIGGERS.BRACE:
			return brace(action_to_react, reacting_unit, acting_unit)
		_:
			return []


# Activated when action is a MoveAction and target unit moves in threat unit from active unit
func overwatch(action_to_react: ResolvedAction, reacting_unit: Unit, acting_unit: Unit) -> Array[BaseAction]:
	var active_threat_weapons: Array[BaseAction] = []
	# Only trigger if:
	# 1. There is a movement order in the resolved action
	# 2. The reacting unit is different than the acting unit
	
	
	if action_to_react.movement.is_empty():
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


func brace(action_to_react: ResolvedAction, reacting_unit: Unit, acting_unit: Unit) -> Array[BaseAction]:
	var out: Array[BaseAction] = []
	# Only trigger if:
	# 1. There is a damage order in the resolved action
	# 2. The reacting unit is different than the acting unit
	# 3. The reacting_unit is the same as the target_unit from the resolved_acton
	
	if action_to_react.damages.is_empty():
		return out
	
	if reacting_unit == acting_unit:
		return out
	
	if not reacting_unit == action_to_react.damages[0].target_unit:
		return out
	
	# This will fail since this method has no way of knowing which target has the action
	out.push_back(brace_action)
	return out
