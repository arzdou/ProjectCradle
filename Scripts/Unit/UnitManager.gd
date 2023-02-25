# This class will be in charge of organizing the different units that are genereated for each encounter
# 1. Unit positions and movement
# 2. Active unit tracking

extends Node
class_name UnitManager

var grid: Resource = preload("res://Resources/Grid.tres")
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


func check_possible_engagement(cell: Vector2) -> Array:
	# Find all units that unit will be engaged if it was in cell
	var engaged_units := []
	
	for direction in grid.directions():
		# Two conditions to NOT stop the path
		# 1. No occupied unit in each direction
		# 2. If occupied: Unit is on the same team
		
		if not get_occupied_cells().has(cell + direction): 
			continue
		
		var close_unit = in_cell(cell+direction)
		if close_unit.team == active_unit.team: 
			continue
			
		engaged_units.push_back(close_unit)
	
	return engaged_units

func move_active_unit(new_cell: Vector2, path: Array) -> bool:
	
	if new_cell == active_unit.cell:
		# If the new_cell is the same one as the previous one the movement is directly completed
		return true
	
	if get_occupied_cells().has(new_cell):
		return false
	
	# Before moving break the engagement from the previous location
	for old_engagned_unit in active_unit.status[CONSTANTS.STATUS.ENGAGED]:
		old_engagned_unit.status[CONSTANTS.STATUS.ENGAGED].erase(active_unit)
	active_unit.status[CONSTANTS.STATUS.ENGAGED].clear()
	
	active_unit.walk_along(path)
	yield(active_unit, "walk_finished")
	
	# After moving to the correct position, engage the units with one another
	for engaged_unit in check_possible_engagement(path[-1]):
		active_unit.status[CONSTANTS.STATUS.ENGAGED].push_back(engaged_unit)
		engaged_unit.status[CONSTANTS.STATUS.ENGAGED].push_back(active_unit)
		
	return true


func update_hud(cursor_cell: Vector2) -> void:
	# Hide all huds except the active unit and the hovered unit
	for unit in _unit_list:
		if unit == active_unit:
			pass
		if unit.cell == cursor_cell:
			unit.show_hud()
		else:
			unit.hide_hud()


func show_side_menu(value: bool) -> void:
	if not active_unit:
		return
		
	active_unit.is_selecting_action = value


func finish_turn() -> void:
	active_unit.finish_turn()
