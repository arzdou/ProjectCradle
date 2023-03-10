extends Node
class_name ActionProcessor

signal move_unit(new_cell)

var CONSTANTS: Resource = preload("res://Resources/CONSTANTS.tres")

var _units
var _performing_action 
var active_unit: Unit
var _action_mode: int
var _cover := {}

var marked_cells := [] # Indicates the range of the weapon
var damage_cells := [] # Indicates the damage area
var move_cells := []   # Indicates movement
var draw_arrows := false

var active := false

@onready var _unit_manager = $"../UnitManager"

var damage_string: String = "%s dealt %d %s damage to %s"


func initialize(action, action_mode: int, cover: Dictionary):
	_units = _unit_manager._unit_list
	active_unit = _unit_manager.active_unit
	
	_performing_action = action
	_action_mode = action_mode
	_cover = cover
	
	active = true

func stop():
	_units = []
	active_unit = null
	_performing_action = null
	_action_mode = 0
	_cover = {}
	
	marked_cells.clear()
	damage_cells.clear()
	move_cells.clear()
				
	active = false


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
		return -2
	
	if _cover['soft'].has(line_of_sight[-2]):
		return -1
		
	for cell in line_of_sight:
		if _cover['hard'].has(cell):
			return -1
			
	return 0


# Perform an attack roll against a character
func attack_roll(target_unit: Unit, range_type: int) -> bool:
		
	# Attacks to invisible characters miss half of the time
	if target_unit.status[CONSTANTS.STATUS.INVISIBLE]:
		var coin_toss = randi()%2
		if coin_toss:
			LogRepeater.write("%s's attack missed since the enemy is invisible!" % active_unit.mech_name)
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
	
	var roll_array := []
	for _i in range(1 + accuracy):
		roll_array.push_back(randi() % 20 + 1)
	roll_array.sort()
	
	var shift: int = accuracy if accuracy>0 else 0 # Shift the array to get the highest or lowest values
	var roll = GlobalGrid.sum_int_array(roll_array.slice(shift, 1 + shift))
	
	return roll + active_unit._stats.grit >= target_unit._stats.evasion


func try_to_apply_damage(target_cell: Vector2, damage_array: Array, range_type:int) -> bool:
	# This function tries to apply an array of damage on top of a cell, if the cell is empty it will 
	# return false and if the damage was applied it will return true
	
	# There are two conditions to apply damage:
	# 1. The cell has a unit
	# 2. You cannot be the target
	
	var target_unit: Unit = GlobalGrid.in_cell(target_cell)
	
	if not target_unit:
		return false
		
	if target_unit == active_unit:
		return false
	
	# Roll to see if the attack connects
	if not attack_roll(target_unit, range_type):
		target_unit.take_damage(0, 0)
		return true
	
	if _performing_action.is_on_hit:
		_performing_action.on_hit.apply_effect(active_unit, target_unit)
	
	for damage_resource in damage_array:
		var damage_dealt = damage_resource.roll_damage()
		target_unit.take_damage(damage_dealt, damage_resource.type)
	
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
		var range_type = _performing_action.ranges[_action_mode].type #For now only first type
		var range_value = _performing_action.ranges[_action_mode].range_value
		var range_blast = _performing_action.ranges[_action_mode].blast
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
		var move_range_value: int
		match _performing_action.move_range:
			CONSTANTS.MOVE_RANGE_TYPES.MAX:
				move_range_value = active_unit.move_range
			CONSTANTS.MOVE_RANGE_TYPES.REMAINING:
				print(active_unit.used_move_range)
				move_range_value = active_unit.remaining_move_range
			CONSTANTS.MOVE_RANGE_TYPES.VALUE:
				move_range_value = _performing_action.move_range_value
		
		draw_arrows = true
		marked_cells.clear()
		move_cells.clear()
		move_cells = GlobalGrid.flood_fill(active_unit.cell, move_range_value)
		
		if execute and move_cells.has(target_cell):
			draw_arrows = false
			emit_signal("move_unit", target_cell)
			return true
	
	if _performing_action.action_type == CONSTANTS.ACTION_TYPES.MISC:
		_performing_action.effect.apply_effect(active_unit, null)
		return true
	
	return false


