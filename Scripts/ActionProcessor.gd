extends Node
class_name ActionProcessor

signal move_unit(new_cell)
signal about_to_act(action)

var action 
var active_unit: Unit
var action_mode: int

var active := false

func initialize(_active_unit: Unit, _action: BaseAction, _action_mode: int,):
	active_unit = _active_unit
	
	action = _action
	action_mode = _action_mode
	
	active = true

func stop():
	active_unit = null
	action = null
	action_mode = 0
	
	active = false


func get_overlay_cells(target_cell: Vector2) -> Dictionary:
	if not active:
		return {}
	return action.get_cells_in_range(active_unit, target_cell)


func try_to_act(target_cell: Vector2) -> bool:
	emit_signal("about_to_act", action)
	var has_acted = await action.try_to_act(active_unit, target_cell)
	return has_acted


func _on_unit_manager_overwatch_triggered(weapon: WeaponAction, range_mode: int, _active_unit: Unit, target_unit: Unit):
	initialize(_active_unit, weapon, range_mode)
	var has_reacted = await try_to_act(target_unit.cell)
	if has_reacted:
		_active_unit.reaction_charges -= 1
	stop()
