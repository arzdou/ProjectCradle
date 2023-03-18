# This resource is used to check if reactions are activated when actions are 
# performed in the GameBoard 

extends Resource
class_name TriggerResource

enum  LOGIC {AND, OR}

@export var is_overwatch: bool
@export var is_bracing: bool
@export var trigger_logic: LOGIC = LOGIC.AND


func check_trigger(action: BaseAction, reacting_unit: Unit, acting_unit: Unit) -> bool:
	# Returns true for "and" and false for "or" which is needed for a good behaviour afterwards
	var out = not add_bool(false, true) 
			
	if is_overwatch:
		out = add_bool(out, overwatch(action, reacting_unit, acting_unit))
			
	return out


# Perform the boolean algebra based on the trigger logic variable.
# Default to "and" (should not be anything else)
func add_bool(v1: bool, v2: bool) -> bool:
	if trigger_logic == LOGIC.OR:
		return v1 or v2
	return v1 and v2


# Activated when action is a MoveAction and target unit moves in threat unit from active unit
func overwatch(action: BaseAction, reacting_unit: Unit, acting_unit: Unit) -> bool:
	if not action is MoveAction:
		return false
	
	if reacting_unit == acting_unit:
		return false
	
	var threat_dict: Dictionary = reacting_unit.get_threat()
	
	# Find which of the threat weapons are in range
	var active_threat_weapons: Array[BaseAction] = []
	for weapon in threat_dict:
		var mode = threat_dict[weapon]
		weapon.range_mode = mode
		if weapon.is_in_range(reacting_unit.cell, acting_unit.cell): # Think a way of doing it
			active_threat_weapons.push_back(weapon)
	
	if active_threat_weapons.is_empty():
		return false
	
	return true
	
