extends Node
class_name ActionProcessor

signal move_unit(new_cell)

var CONSTANTS: Resource = preload("res://Resources/CONSTANTS.tres")

var action 
var active_unit: Unit
var action_mode: int

var marked_cells := [] # Indicates the range of the weapon
var damage_cells := [] # Indicates the damage area
var move_cells := []   # Indicates movement
var draw_arrows := false

var active := false

var damage_string: String = "%s dealt %d %s damage to %s"


func initialize(_active_unit: Unit, _action: BaseAction, _action_mode: int,):
	active_unit = _active_unit
	
	action = _action
	action_mode = _action_mode
	
	marked_cells.clear()
	damage_cells.clear()
	move_cells.clear()
	
	active = true

func stop():
	active_unit = null
	action = null
	action_mode = 0
	
	active = false


func get_overlay_cells() -> Dictionary:
	var action_cells := {
		CONSTANTS.UOVERLAY_CELLS.MARKED: marked_cells,
		CONSTANTS.UOVERLAY_CELLS.MOVEMENT: move_cells,
		CONSTANTS.UOVERLAY_CELLS.DAMAGE: damage_cells
	}
	return action_cells


func process_action_targeted(target_cell: Vector2, execute: bool = false) -> bool:
	# This function processes all events after an action has been selected.

	if action.action_type == CONSTANTS.ACTION_TYPES.WEAPON:
		var range_dict = action.get_cells_in_range(
			active_unit.cell, target_cell, action_mode
		)
		marked_cells = range_dict["in_range"]
		damage_cells = range_dict["damaged"]
		move_cells.clear()
		if execute:
			return action.try_to_apply_damage_in_area(active_unit, damage_cells, action_mode)
	
	if action.action_type == CONSTANTS.ACTION_TYPES.MOVEMENT:
		var move_range_value: int
		match action.move_range:
			CONSTANTS.MOVE_RANGE_TYPES.MAX:
				move_range_value = active_unit.move_range
			CONSTANTS.MOVE_RANGE_TYPES.REMAINING:
				move_range_value = active_unit.remaining_move_range
			CONSTANTS.MOVE_RANGE_TYPES.VALUE:
				move_range_value = action.move_range_value
		
		draw_arrows = true
		marked_cells.clear()
		move_cells.clear()
		move_cells = GlobalGrid.flood_fill(active_unit.cell, move_range_value)
		
		if execute and move_cells.has(target_cell):
			draw_arrows = false
			emit_signal("move_unit", target_cell)
			return true
	
	if action.action_type == CONSTANTS.ACTION_TYPES.MISC:
		if not action.effect:
			return true
		action.effect.apply_effect(active_unit, null)
		return true
	
	return false


func _on_unit_manager_overwatch_triggered(weapon: WeaponAction, range_mode: int, _active_unit: Unit, target_unit: Unit):
	initialize(_active_unit, weapon, range_mode)
	process_action_targeted(target_unit.cell, true)
	stop()
