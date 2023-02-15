# This class will be in charge of organizing the different units that are genereated for each encounter
# 1. Unit positions and movement
# 2. Active unit tracking

extends Node
class_name UnitManager

const Unit: PackedScene = preload("res://Scenes/Unit/Unit.tscn")

var active_unit: Unit = null
var _unit_list := []
var _teams = []


func initialize(units_data: Array) -> void:
	# Create the different units based on the input data
	for udata in units_data:
		var unit = Unit.instance()
		add_child(unit)
		
		unit.set_owner(self)
		
		unit.initialize(udata)
		_unit_list.push_back(unit)
		
		if not unit.team in _teams:
			_teams.push_back(unit.team)
		
		unit.connect("action_selected", get_parent(), "_on_Unit_action_selected")


func get_occupied_cells() -> Array:
	# Returns all positions of the units
	var out := []
	for unit in _unit_list:
		out.push_back(unit.cell)
	return out


func in_cell(cell: Vector2) -> Unit:
	# Returns the unit located at 'cell'
	for unit in _unit_list:
		if unit.cell == cell:
			return unit
	return null


func try_selecting_unit(cell: Vector2, active_team) -> bool:
	
	var possible_unit: Unit = in_cell(cell)
	
	if not possible_unit:
		return false
	
	if not possible_unit.team == active_team:
		return false
	
	active_unit = possible_unit
	active_unit.is_selected = true
	return true


func deselect_unit() -> void:
	if not active_unit:
		return
	active_unit.is_selected = false
	active_unit.is_selecting_action = false
	active_unit = null


func get_active_move_range() -> int:
	return active_unit.move_range


func move_active_unit(new_cell: Vector2, path: Array) -> bool:
	
	if new_cell == active_unit.cell:
		# If the new_cell is the same one as the previous one the movement is directly completed
		return true
	
	if get_occupied_cells().has(new_cell):
		return false
	
	active_unit.walk_along(path)
	yield(active_unit, "walk_finished")
	
	return true


func update_hud(cursor_cell: Vector2) -> void:
	# Hide all huds except the active unit and the hovered unit
	for unit in _unit_list:
		if unit == active_unit or unit.cell == cursor_cell:
			unit.show_hud()
		else:
			unit.hide_hud()


func show_side_menu(value: bool) -> void:
	if not active_unit:
		return
	
	active_unit.is_selecting_action = value


func finish_turn() -> void:
	active_unit.finish_turn()
