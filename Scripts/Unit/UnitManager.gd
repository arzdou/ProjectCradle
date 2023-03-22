# This class will be in charge of organizing the different units that are genereated for each encounter
# 1. Unit positions and movement
# 2. Active unit tracking

extends Node
class_name UnitManager

signal prompt_created(prompt_menu, text, arr)
signal reactions_processed

const Unit: PackedScene = preload("res://Scenes/Unit/Unit.tscn")
const PromptMenu: PackedScene = preload("res://Scenes/UI/PromptMenu.tscn")

var active_unit: Unit = null
var unit_list: Array[Unit] = []
var _teams: Array[String] = []


func initialize(units_data: Array) -> void:
	# Create the different units based on the input data
	for udata in units_data:
		var unit = Unit.instantiate()
		add_child(unit)
		
		unit.set_owner(self)
		
		unit.initialize(udata)
		unit_list.push_back(unit)
		
		if not unit.team in _teams:
			_teams.push_back(unit.team)
		

func deselect_unit() -> void:
	if not active_unit:
		return
	active_unit.is_selected = false
	active_unit = null


func get_active_move_range() -> int:
	return active_unit.move_range


func move_active_unit(new_cell: Vector2, path: Array) -> bool:
	
	#await check_overwatch()
	
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
	for unit in unit_list:
		if unit == active_unit:
			pass
		if unit.cell == cursor_cell:
			unit.show_hud()
		else:
			unit.hide_hud()


# Updates the engagement of all units in the field.
func update_engagement():
	for unit in unit_list:
		# Disengagement is taken into account on the engaged_units setter
		unit.engaged_units = GlobalGrid.get_neighbours(unit.cell)


func finish_turn() -> void:
	active_unit.finish_turn()
	update_engagement()
	deselect_unit()


func process_reactions(resolved_action: ResolvedAction):
	for reacting_unit in unit_list:
		if reacting_unit.reaction_charges <= 0:
			continue
		for reaction in reacting_unit._stats.reactions:
			
			if not reacting_unit._stats.is_reaction_active[reaction]:
				continue
			
			var possible_actions = reaction.get_possible_reactions(resolved_action, reacting_unit, active_unit)
			if possible_actions.is_empty():
				continue
				
			var prompt_menu = PromptMenu.instantiate()
			emit_signal("prompt_created", prompt_menu, reaction.prompt_text, possible_actions)
			var selected_action: BaseAction = await prompt_menu.action_selected
			
			if not selected_action:
				continue
			
			var new_resolved_action = selected_action.process(reacting_unit, active_unit.cell)
			await new_resolved_action.do()
			prompt_menu.queue_free()
	
	emit_signal("reactions_processed")
