# Command pattern for actions.
class_name ResolvedAction

# Variables contained in the PackedAction
var action: BaseAction
var acting_unit: Unit
var target_cell: Vector2
var options: Dictionary # Contains extra parameters specific to the action, e.g. range_mode for a weapon

var has_actions: bool

var is_done: bool
var next_action: ResolvedAction

# Variables that contain all the changes performed
var damages: Array[Dictionary] = []
var status: Array[Dictionary] = []
var conditions: Array[Dictionary] = []
var movement: Array[Dictionary] = []

func _init(_action: BaseAction, _acting_unit: Unit, _target_cell: Vector2, _options: Dictionary = {}):
	action = _action
	acting_unit = _acting_unit
	target_cell = _target_cell
	options = _options


# Perform the action specified on the action_result dictionary
func do():
	if is_done:
		return
	
	for move in movement:
		move.unit.walk_along(move.path)
		await move.unit.walk_finished
	
	for damage in damages:
		damage.target_unit.take_damage(damage.value, damage.type)
	
	for stat in status:
		stat.target_unit.set_status(stat.status, stat.value)
	
	for cond in conditions:
		cond.target_unit.set_condition(cond.condition, cond.value)
	
	is_done = true


# Undo the action specified on the action_result dictionary
func undo():
	if not is_done:
		return
	is_done = false


func add_movement(unit: Unit, path: PackedVector2Array):
	movement.push_back(
		{
			"unit": unit,
			"path": path,
		}
	)
	has_actions = true


func add_damage(dealing_unit: Unit, target_unit: Unit, value: int, type: CONSTANTS.DAMAGE_TYPES): 
	damages.push_back(
		{
			"dealing_unit": dealing_unit,
			"target_unit": target_unit,
			"value": value,
			"type": type
		}
	)
	has_actions = true


func add_status(dealing_unit: Unit, target_unit: Unit, stat: CONSTANTS.STATUS, value: bool):
	status.push_back(
		{
			"dealing_unit": dealing_unit,
			"target_unit": target_unit,
			"status": stat,
			"value": value
		}
	)
	has_actions = true


func add_conditions(dealing_unit: Unit, target_unit: Unit, condition: CONSTANTS.CONDITIONS, time: int):
	status.push_back(
		{
			"dealing_unit": dealing_unit,
			"target_unit": target_unit,
			"condition": condition,
			"time": time
		}
	)
	has_actions = true


func add_effect(effect: EffectResource, self_unit: Unit, target_unit: Unit): 
	for ss in effect.self_status:
		add_status(self_unit, self_unit, ss, true)

	for ts in effect.target_status:
		add_status(self_unit, target_unit, ts, true)
	
	for sc in effect.self_conditions:
		add_conditions(self_unit, self_unit, sc, 1)

	for tc in effect.target_conditions:
		add_conditions(self_unit, target_unit, tc, 1)
	
	#overcharge
	#disengage
	#brace
	
	has_actions = true
