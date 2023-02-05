extends Node
class_name ActionProcessor

export var _grid: Resource = preload("res://Resources/Grid.tres")
var CONSTANTS: Resource = preload("res://Resources/CONSTANTS.tres")

var _units
var _performing_action 
var _performing_unit: Unit


func initialize(units, action, unit):
	_units = units
	_performing_action = action
	_performing_unit = unit


func stop():
	_units = null
	_performing_action = null
	_performing_unit = null


func get_walkable_cells(unit: Unit) -> Array:
	var blocked_spaces = _units.keys()
	return _grid.flood_fill(unit.cell, unit.move_range, blocked_spaces)


func get_visible_cells(unit: Unit, vision_range: int) -> Array:
	var blocked_spaces = _units.keys()
	return _grid.flood_fill(unit.cell, vision_range, blocked_spaces, false) # This shuld be updated


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


func apply_damage(recieving_unit: Unit, damage: int, damage_type: int) -> void:
	recieving_unit.take_damage(damage, damage_type)
	recieving_unit.show_hud()


func process_action_targeted(target_cell: Vector2) -> bool:
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
	
	if _performing_action.action_type == CONSTANTS.ACTION_TYPES.WEAPON:
		# For now only range types
		var range_type = _performing_action.weapon_range.keys()[0] #For now only first type
		var shooting_range: int = _performing_action.weapon_range[range_type]
		var all_damage: Array = _performing_action.weapon_damage
		var mouse_angle: float = _performing_unit.cell.angle_to_point(target_cell)
		
		match range_type: 
			CONSTANTS.WEAPON_RANGE_TYPES.RANGE:
				var _marked_cells = get_visible_cells(_performing_unit, shooting_range)
				if not _units.has(target_cell):
					return false
				
				if _units[target_cell] == _performing_unit:
					return false
				
				for damage in all_damage:
					var damage_type: int = damage.keys()[0]
					apply_damage(_units[target_cell], roll_damage(damage), damage_type)
				
				return true
			
			CONSTANTS.WEAPON_RANGE_TYPES.LINE:
				var damage_applied := false
				var _marked_cells = _grid.ray_cast_from_cell(_performing_unit.cell, mouse_angle, shooting_range)
				for marked_cell in _marked_cells:
					# Only shoot the enemies that:
					# 1. Are in the _marked_cell array
					# 2. Are not you
					
					if not _units.has(marked_cell):
						continue
					
					if _units[marked_cell] == _performing_unit:
						continue
						
					for damage in all_damage:
						var damage_type: int = damage.keys()[0]
						apply_damage(_units[marked_cell], roll_damage(damage), damage_type)
						damage_applied = true
					
				if not damage_applied:
					return false
			CONSTANTS.WEAPON_RANGE_TYPES.CONE:
				pass
				
			CONSTANTS.WEAPON_RANGE_TYPES.BLAST:
				pass
				
			CONSTANTS.WEAPON_RANGE_TYPES.BURST:
				pass
	
	return true


