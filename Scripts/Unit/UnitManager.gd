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

@onready var action_processor = $ActionProcessor

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
		
		unit.connect("action_selected",Callable(get_parent(),"_on_Unit_action_selected"))


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


func check_overwatch():
	for unit in unit_list:
		if unit == active_unit:
			continue
		
		if unit.reaction_charges <= 0:
			continue
		
		var threat_weapons = unit.get_threat()
		
		# Find which of the threat weapons are in range
		var active_threat_weapons: Array[BaseAction] = []
		for weapon in threat_weapons:
			var cells_in_range = weapon.ranges[0].get_cells_in_range(unit.cell, Vector2(0,0))
			if active_unit.cell in cells_in_range["in_range"]:
				active_threat_weapons.push_back(weapon)
		
		if active_threat_weapons.is_empty():
			continue
		
		var prompt_menu = PromptMenu.instantiate()
		var prompt_text = "OVERWATCH TRIGGERED! Choose weapon:"
		emit_signal("prompt_created", prompt_menu, prompt_text, active_threat_weapons)
		
		var selected_weapon = await prompt_menu.action_selected
		
		if selected_weapon:
			emit_signal("overwatch_triggered", selected_weapon, 0, unit, active_unit)
		prompt_menu.queue_free()


func finish_turn() -> void:
	active_unit.finish_turn()
	update_engagement()
	deselect_unit()


func process_reactions(action):
	for reacting_unit in unit_list:
		if reacting_unit.reaction_charges <= 0:
			continue
		for reaction in reacting_unit._stats.reactions:
			var possible_actions = reaction.get_possible_reactions(action, reacting_unit, active_unit)
			print(possible_actions)
			if possible_actions.is_empty():
				continue
				
			var prompt_menu = PromptMenu.instantiate()
			emit_signal("prompt_created", prompt_menu, reaction.prompt_text, possible_actions)
			var selected_action: BaseAction = await prompt_menu.action_selected
			
			if not selected_action:
				continue
			
			selected_action.try_to_act(reacting_unit, active_unit.cell)
			prompt_menu.queue_free()
	
	emit_signal("reactions_processed")
