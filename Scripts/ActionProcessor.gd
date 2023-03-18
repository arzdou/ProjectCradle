extends Node
class_name ActionProcessor

signal move_unit(new_cell)
signal about_to_act(action)

var action 
var active_unit: Unit
var action_mode: int
var active := false

var unit_manager

func _ready():
	unit_manager = get_parent()

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
	return action.get_cells_in_range(active_unit, target_cell)


func try_to_act(target_cell: Vector2) -> bool:
	unit_manager.process_reactions(action)
	await unit_manager.reactions_processed
	var has_acted = await action.try_to_act(active_unit, target_cell)
	return has_acted

