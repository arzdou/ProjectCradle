extends Node
class_name ActionProcessor

signal move_unit(new_cell, new_state)

export var _grid: Resource = preload("res://Resources/Grid.tres")
var CONSTANTS: Resource = preload("res://Resources/CONSTANTS.tres")

var _units
var _performing_action 
var _performing_unit: Unit
var _blocked_cells := []

var marked_cells := [] # Indicates the range of the weapon
var damage_cells := [] # Indicates the damage area
var move_cells := []   # Indicates movement
var draw_arrows := false

onready var _unit_manager = $"../UnitManager"


func initialize(action, blocked_cells):
	_units = _unit_manager._unit_list
	_performing_action = action
	_performing_unit = _unit_manager.active_unit
	_blocked_cells = blocked_cells


func stop():
	_units = null
	_performing_action = null
	_performing_unit = null


func get_overlay_cells() -> Dictionary:
	var action_cells := {}
	
	for d_cell in damage_cells:
		action_cells[d_cell] = CONSTANTS.UOVERLAY_CELLS.DAMAGE
		
	for m_cell in marked_cells:
		if action_cells.has(m_cell):
			continue
		action_cells[m_cell] = CONSTANTS.UOVERLAY_CELLS.MARKED
		
	for m_cell in move_cells:
		if action_cells.has(m_cell):
			continue
		action_cells[m_cell] = CONSTANTS.UOVERLAY_CELLS.MOVEMENT
		
	return action_cells


func roll_damage(damage_dict: Dictionary) -> int:
	# The dictionary can take two shapes:
	# 1. {CONSTANTS.TYPES_DAMAGE, int}     fixed value
	# 1. {CONSTANTS.TYPES_DAMAGE, String}  random value
	var damage = damage_dict.values()[0]
	if typeof(damage) == TYPE_INT:
		return damage
	
	# If not its a string of shape 'ndM' where n is the number of M dices
	var number_of_dices := int(damage[0])
	var type_of_dice := int(damage[-1])
	var out_damage := 0 # this is the variable that we will return
	for _i in range(number_of_dices):
		out_damage += randi() % type_of_dice + 1
	return out_damage


func try_to_apply_damage(target_cell: Vector2, damage_array: Array) -> bool:
	# This function tries to apply an array of damage on top of a cell, if the cell is empty it will 
	# return false and if the damage was applied it will return true
	
	# There are two conditions to apply damage:
	# 1. The cell has a unit
	# 2. You cannot be the target
	var recieving_unit: Unit = null
	
	for unit in _units:
		if target_cell == unit.cell:
			recieving_unit = unit
	
	if not recieving_unit:
		return false
	
	if recieving_unit == _performing_unit:
		return false

	for damage in damage_array:
		var damage_type: int = damage.keys()[0]
		recieving_unit.take_damage(roll_damage(damage), damage_type)
		recieving_unit.show_hud()
	
	return true


func try_to_apply_damage_in_area(area: Array, damage_array: Array) -> bool:
	# Same as before but now we do it in an area, defined as an array of cells
	var damage_applied := false
	for target_cell in area:
		# If *any* damage was done consider this action complete
		damage_applied = damage_applied or try_to_apply_damage(target_cell, damage_array)
		
	return damage_applied



func process_action_targeted(target_cell: Vector2, execute: bool = false) -> bool:
	# This function processes all events after an action has been selected. It will probably be very
	# large and convoluted but its behaviour is not very complicated.
	
	# When this function is called the GameBoard can only be in an ACTING state, which means that 
	# there exist a _performing_action and an _active unit. This function will take those two values 
	# and the cell the user has clicked on. It will then find what type of action we are performing 
	# and try to complete it. If the action was completed the function will return true and the state 
	# of the game will change to FREE, after all the consequences of the action have been processed.
	# If the action was not valid the function will return false and the state of the GameBoard is preserved
	
	# TODO: Probably it would be intelligent to isolate this behaviour in its own node since it will get pretty fucking chonky
	# Also create new funcions for every type of action would help with readability
	var mouse_angle: float = _performing_unit.cell.angle_to_point(target_cell)
	
	if _performing_action.action_type == CONSTANTS.ACTION_TYPES.WEAPON:
		# For now only range types
		var range_type = _performing_action.weapon_range.keys()[0] #For now only first type
		var shooting_range = _performing_action.weapon_range[range_type]
		var damage_array: Array = _performing_action.weapon_damage
		
		match range_type: 
			CONSTANTS.WEAPON_RANGE_TYPES.RANGE:
				marked_cells = _grid.ray_cast_circular(_performing_unit.cell, shooting_range, _blocked_cells)
				damage_cells = [target_cell]
				if execute and marked_cells.has(target_cell):
					return try_to_apply_damage(target_cell, damage_array)
			
			CONSTANTS.WEAPON_RANGE_TYPES.LINE:
				marked_cells.clear()
				damage_cells = _grid.ray_cast_from_cell(_performing_unit.cell, mouse_angle, shooting_range, _blocked_cells)
				if execute:
					return try_to_apply_damage_in_area(damage_cells, damage_array)
			
			CONSTANTS.WEAPON_RANGE_TYPES.CONE:
				marked_cells.clear()
				damage_cells = _grid.cone_from_cell(_performing_unit.cell, mouse_angle, shooting_range, _blocked_cells)
				if execute:
					return try_to_apply_damage_in_area(damage_cells, damage_array)
				
			CONSTANTS.WEAPON_RANGE_TYPES.BLAST:
				# For blast, shooting range should be an Vector2 of [range, blast radius]
				marked_cells = _grid.ray_cast_circular(_performing_unit.cell, shooting_range.x, _blocked_cells)
				damage_cells = _grid.ray_cast_circular(target_cell, shooting_range.y, _blocked_cells)
				if execute:
					return try_to_apply_damage_in_area(damage_cells, damage_array)
				
			CONSTANTS.WEAPON_RANGE_TYPES.BURST:
				marked_cells.clear()
				damage_cells = _grid.ray_cast_circular(_performing_unit.cell, shooting_range, _blocked_cells)
				if execute:
					return try_to_apply_damage_in_area(damage_cells, damage_array)
					
	if _performing_action.action_type == CONSTANTS.ACTION_TYPES.MOVEMENT:
		if _performing_action.action_name == "BOOST":
			draw_arrows = true
			move_cells = _grid.flood_fill(_performing_unit.cell, _performing_unit.move_range, _blocked_cells)
			if execute and move_cells.has(target_cell):
				draw_arrows = false
				emit_signal("move_unit", target_cell, CONSTANTS.BOARD_STATE.SELECTING)
				return false
	
	return false


