extends Node
class_name ActionProcessor

signal move_unit(new_cell, new_state)

var CONSTANTS: Resource = preload("res://Resources/CONSTANTS.tres")

var _units
var _performing_action 
var active_unit: Unit
var _blocked_cells := []
var _cover := {}

var marked_cells := [] # Indicates the range of the weapon
var damage_cells := [] # Indicates the damage area
var move_cells := []   # Indicates movement
var draw_arrows := false

onready var _unit_manager = $"../UnitManager"

var damage_string: String = "%s dealt %d %s damage to %s"


func initialize(action, cover: Dictionary):
	_units = _unit_manager._unit_list
	_performing_action = action
	active_unit = _unit_manager.active_unit
	_cover = cover


func stop():
	_units = null
	_performing_action = null
	active_unit = null


func get_overlay_cells() -> Dictionary:
	var action_cells := {
		CONSTANTS.UOVERLAY_CELLS.MARKED: marked_cells,
		CONSTANTS.UOVERLAY_CELLS.MOVEMENT: move_cells,
		CONSTANTS.UOVERLAY_CELLS.DAMAGE: damage_cells
	}
	return action_cells


func find_cover_from_attack(target_unit: Unit) -> int:
	var mouse_angle: float = active_unit.cell.angle_to_point(target_unit.cell)
	var distance = active_unit.cell.distance_to(target_unit.cell)
	var line_of_sight = GlobalGrid.ray_cast_from_cell(active_unit.cell, mouse_angle, distance)
	
	if _cover['hard'].has(line_of_sight[-2]):
		return 2
	
	if _cover['soft'].has(line_of_sight[-2]):
		return 1
		
	for cell in line_of_sight:
		if _cover['hard'].has(cell):
			return 1
			
	return 0


func try_to_apply_damage(target_cell: Vector2, damage_array: Array, range_type:int) -> bool:
	# This function tries to apply an array of damage on top of a cell, if the cell is empty it will 
	# return false and if the damage was applied it will return true
	
	# There are two conditions to apply damage:
	# 1. The cell has a unit
	# 2. You cannot be the target
	var target_unit: Unit = null
	
	for unit in _units:
		if target_cell == unit.cell:
			target_unit = unit
	
	if not target_unit:
		return false
	
	if target_unit == active_unit:
		return false
	
	if target_unit.status[CONSTANTS.STATUS.INVISIBLE]:
		var coin_toss = randi()%2
		if coin_toss:
			# Damage avoided
			return true
	
	var accuracy: int = 0
	if active_unit.status[CONSTANTS.STATUS.ENGAGED] and range_type != CONSTANTS.WEAPON_RANGE_TYPES.THREAT:
		accuracy -= 1
	if target_unit.status[CONSTANTS.STATUS.EXPOSED]:
		accuracy += 1
	if target_unit.status[CONSTANTS.STATUS.PRONE]:
		accuracy += 1
	if active_unit.conditions[CONSTANTS.CONDITIONS.IMPAIRED]:
		accuracy -= 1
	
	accuracy += find_cover_from_attack(target_unit)
	
	for damage_resource in damage_array:
		var damage_type: int = damage_resource.type
		var damage_dealt = damage_resource.roll_damage(accuracy)
		target_unit.take_damage(damage_dealt, damage_type)
		target_unit.show_hud()
		LogRepeater.write(
			damage_string %[active_unit.mech_name, damage_dealt, CONSTANTS.DAMAGE_TYPES.keys()[damage_type], target_unit.mech_name]
		)
	return true


func try_to_apply_damage_in_area(area: Array, damage_array: Array, range_type: int) -> bool:
	# Same as before but now we do it in an area, defined as an array of cells
	var damage_applied := false
	for target_cell in area:
		# If *any* damage was done consider this action complete
		damage_applied = damage_applied or try_to_apply_damage(target_cell, damage_array, range_type)
		
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
	var mouse_angle: float = active_unit.cell.angle_to_point(target_cell)
	
	if _performing_action.action_type == CONSTANTS.ACTION_TYPES.WEAPON:
		# For now only range types
		var range_type = _performing_action.ranges[0].type #For now only first type
		var range_value = _performing_action.ranges[0].range_value
		var range_blast = _performing_action.ranges[0].blast
		var damage_array: Array = _performing_action.damage
		
		match range_type: 
			CONSTANTS.WEAPON_RANGE_TYPES.RANGE:
				marked_cells = GlobalGrid.line_of_sight(active_unit.cell, range_value)
				damage_cells = [target_cell]
				move_cells.clear()
				if execute and marked_cells.has(target_cell):
					return try_to_apply_damage(target_cell, damage_array, range_type)
			
			CONSTANTS.WEAPON_RANGE_TYPES.LINE:
				marked_cells.clear()
				damage_cells = GlobalGrid.ray_cast_from_cell(active_unit.cell, mouse_angle, range_value)
				move_cells.clear()
				if execute:
					return try_to_apply_damage_in_area(damage_cells, damage_array, range_type)
			
			CONSTANTS.WEAPON_RANGE_TYPES.CONE:
				marked_cells.clear()
				damage_cells = GlobalGrid.cone_from_cell(active_unit.cell, mouse_angle, range_value)
				move_cells.clear()
				if execute:
					return try_to_apply_damage_in_area(damage_cells, damage_array, range_type)
				
			CONSTANTS.WEAPON_RANGE_TYPES.BLAST:
				# For blast, shooting range should be an Vector2 of [range, blast radius]
				marked_cells = GlobalGrid.line_of_sight(active_unit.cell, range_value)
				damage_cells = GlobalGrid.line_of_sight(target_cell, range_blast)
				move_cells.clear()
				if execute:
					return try_to_apply_damage_in_area(damage_cells, damage_array, range_type)
				
			CONSTANTS.WEAPON_RANGE_TYPES.BURST:
				marked_cells.clear()
				damage_cells = GlobalGrid.line_of_sight(active_unit.cell, range_blast)
				move_cells.clear()
				if execute:
					return try_to_apply_damage_in_area(damage_cells, damage_array, range_type)
					
			CONSTANTS.WEAPON_RANGE_TYPES.THREAT:
				marked_cells = GlobalGrid.line_of_sight(active_unit.cell, range_value)
				damage_cells = [target_cell]
				move_cells.clear()
				if execute and marked_cells.has(target_cell):
					return try_to_apply_damage(target_cell, damage_array, range_type)
					
	if _performing_action.action_type == CONSTANTS.ACTION_TYPES.MOVEMENT:
		if _performing_action.name == "BOOST":
			draw_arrows = true
			marked_cells.clear()
			move_cells.clear()
			move_cells = GlobalGrid.flood_fill(active_unit.cell, active_unit.move_range)
			
			if execute and move_cells.has(target_cell):
				draw_arrows = false
				emit_signal("move_unit", target_cell, CONSTANTS.BOARD_STATE.SELECTING)
				return false
	
	return false


