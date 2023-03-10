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
		var unit = Unit.instantiate()
		add_child(unit)
		
		unit.set_owner(self)
		
		unit.initialize(udata)
		_unit_list.push_back(unit)
		
		if not unit.team in _teams:
			_teams.push_back(unit.team)
		
		unit.connect("action_selected",Callable(get_parent(),"_on_Unit_action_selected"))


func deselect_unit() -> void:
	if not active_unit:
		return
	active_unit.is_selected = false
	active_unit.is_selecting_action = false
	active_unit = null


func get_active_move_range() -> int:
	return active_unit.move_range


func move_active_unit(new_cell: Vector2, path: Array) -> bool:
	
	# It is necessary to create a reference to the acting unit since it can be deactivated somewhere 
	# when the function is awaiting the movement end
	var moving_unit = active_unit
	
	if new_cell == active_unit.cell:
		# If the new_cell is the same one as the previous one the movement is directly completed
		return true
	
	if GlobalGrid.get_occupied_cells().has(new_cell):
		return false
	
	# Before moving break the engagement from the previous location
	for old_engagned_unit in moving_unit.status[CONSTANTS.STATUS.ENGAGED]:
		old_engagned_unit.status[CONSTANTS.STATUS.ENGAGED].erase(active_unit)
	if moving_unit.status[CONSTANTS.STATUS.ENGAGED]:
		moving_unit.status[CONSTANTS.STATUS.ENGAGED].clear()
		LogRepeater.create_prompt("- ENGAGED", active_unit.position)
	
	active_unit.walk_along(path)
	await active_unit.walk_finished
	
	# After moving to the correct position, engage the units with one another
	for engaged_unit in GlobalGrid.get_neighbours(path[-1]):
		moving_unit.status[CONSTANTS.STATUS.ENGAGED].push_back(engaged_unit)
		engaged_unit.status[CONSTANTS.STATUS.ENGAGED].push_back(active_unit)
	if moving_unit.status[CONSTANTS.STATUS.ENGAGED]:
		LogRepeater.create_prompt("+ ENGAGED", moving_unit.position)
	
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
	deselect_unit()
