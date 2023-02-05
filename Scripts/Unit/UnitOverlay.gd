# Draws an overlay over an array of cells.
class_name UnitOverlay
extends TileMap

var _grid: Resource = preload("res://Resources/Grid.tres")

var _active_unit = null
var _units = null
var _action = null
var _marked_cells := []

func initialize(units, action, active_unit):
	_active_unit = active_unit
	_units = units
	_action = action

func stop():
	_active_unit = null
	_units = null
	_action = null
	_marked_cells = []


func draw(cells: Array) -> void:
	clear()
	# We loop over the cells and assign them the only tile available in the tileset, tile 0.
	for cell in cells:
		set_cellv(cell, 0)


func update_overlay(cursor_cell: Vector2, mouse_angle: float) -> void:
	
	if _action.action_type == CONSTANTS.ACTION_TYPES.WEAPON:
		# For now only range types
		var range_type = _action.weapon_range.keys()[0] #For now only first type
		var shooting_range: int = _action.weapon_range[range_type]
		
		match range_type: 
			CONSTANTS.WEAPON_RANGE_TYPES.RANGE:
				_marked_cells = _grid.flood_fill(_active_unit.cell, shooting_range)
			
			CONSTANTS.WEAPON_RANGE_TYPES.LINE:
				_marked_cells = _grid.ray_cast_from_cell(_active_unit.cell, mouse_angle, shooting_range)
			
			CONSTANTS.WEAPON_RANGE_TYPES.CONE:
				_marked_cells = _grid.cone_from_cell(_active_unit.cell, mouse_angle, shooting_range)
			
			CONSTANTS.WEAPON_RANGE_TYPES.BLAST:
				_marked_cells = _grid.flood_fill(cursor_cell, shooting_range)
			
			CONSTANTS.WEAPON_RANGE_TYPES.BURST:
				_marked_cells = _grid.flood_fill(_active_unit.cell, shooting_range)
	draw(_marked_cells)
