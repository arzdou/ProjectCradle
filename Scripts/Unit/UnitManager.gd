# This class will be in charge of organizing the different units that are genereated for each encounter
# 1. Unit positions and movement
# 2. Active unit tracking

extends Node
class_name UnitManager

signal overwatch_triggered(weapon, active_unit, target_unit)
signal overwatch_finished

const Unit: PackedScene = preload("res://Scenes/Unit/Unit.tscn")
const PromptMenu: PackedScene = preload("res://Scenes/UI/PromptMenu.tscn")

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
	active_unit = null


func get_active_move_range() -> int:
	return active_unit.move_range


func move_active_unit(new_cell: Vector2, path: Array) -> bool:
	
	check_overwatch()
	await "overwatch_finished"
	print(2)
	
	# It is necessary to create a reference to the acting unit since it can be deactivated somewhere 
	# when the function is awaiting the movement end
	var moving_unit = active_unit
	
	if new_cell == active_unit.cell:
		# If the new_cell is the same one as the previous one the movement is directly completed
		return true
	
	if GlobalGrid.get_occupied_cells().has(new_cell):
		return false
	
	moving_unit.walk_along(path)
	await moving_unit.walk_finished
	update_engagement()
	
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


# Returns all the units contiguous to a given cell
func get_neighbours(cell: Vector2) -> Array[Unit]:
	var neighbours: Array[Unit] = []
	for direction in GlobalGrid.DIRECTIONS:
		var unit = GlobalGrid.in_cell(cell + direction)
		if unit:
			neighbours.push_back(unit)
	return neighbours


# Updates the engagement of all units in the field.
# TODO: Ignores disengaged units
func update_engagement():
	for unit in _unit_list:
		# Ignore disengagement here
		var neighbours = get_neighbours(unit.cell)
		unit.engaged_units = neighbours


func check_overwatch():
	for unit in _unit_list:
		if unit == active_unit:
			continue
		var threat_weapons = unit.get_threat()
		
		# Find which of the threat weapons are in range
		var active_threat_weapons: Array[BaseAction] = []
		for weapon in threat_weapons:
			var range_res = weapon.ranges[0]
			var weapon_range_tiles = GlobalGrid.flood_fill(
				unit.cell, range_res.range_value
			)
			if active_unit.cell in weapon_range_tiles:
				active_threat_weapons.push_back(weapon)
		
		if active_threat_weapons.is_empty():
			continue
		
		var contextual_menu = PromptMenu.instantiate()
		add_child(contextual_menu) # Should be added in hud
		contextual_menu.initialize(
			"OVERWATCH TRIGGERED! Choose weapon:", active_threat_weapons
		)
		
		var selected_weapon = await contextual_menu.action_selected
		
		emit_signal("overwatch_triggered", selected_weapon, 0, unit, active_unit)
		contextual_menu.queue_free()
	
	emit_signal("overwatch_finished")

func finish_turn() -> void:
	active_unit.finish_turn()
	update_engagement()
	deselect_unit()
