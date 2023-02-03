class_name GameBoard
extends YSort

export var _grid: Resource = preload("res://Resources/Grid.tres")

var _directions = _grid.directions()
var _units := {}
var _active_unit: Unit
var _walkable_cells := []

onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _unit_path: UnitPath = $UnitPath 

func _ready() -> void:
	_reinitialize()
	_unit_overlay.draw(get_walkable_cells($Unit))


func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_unit()
		_clear_active_unit()


func _reinitialize() -> void:
	_units.clear()
	
	for child in get_children():
		
		# We can cast cast anything into a Unit, if it doesnt work it returns null
		var unit := child as Unit
		if not unit:
			continue
		
		_units[unit.cell] = unit


func is_occupied(cell: Vector2) -> bool:
	return true if _units.has(cell) else false


func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.move_range)


func _flood_fill(cell: Vector2, move_range: int) -> Array:
	var out := []
	
	# We use a stack of cells to process, when there are no more we exit
	var stack := [cell]
	
	while not stack.empty():
		var current: Vector2 = stack.pop_back()
		# The conditions are:
		# 1. We haven't already visited and filled this cell
		# 2. We didn't go past the grid's limits.
		# 3. We are within the `max_distance`, a number of cells.
		
		if out.has(current):
			continue
		
		var distance_between_cells := (current - cell).abs()
		if distance_between_cells.x + distance_between_cells.y > move_range:
			continue
		
		if not _grid.is_within_bounds(current):
			continue
		
		out.push_back(current)
		
		# Only add new elements to the stack if:
		# 1. They are not repeated
		# 2. They are not occupied
		for direction in _directions:
			var next_cell: Vector2 = current + direction
			if is_occupied(next_cell):
				continue 
			if next_cell in out:
				continue
			stack.push_back(next_cell)
			
	return out


func _select_unit(cell: Vector2) -> void:
	
	if not _units.has(cell):
		return
	
	_active_unit = _units[cell]
	_active_unit.is_selected = true
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)


func _deselect_unit() -> void:
	_active_unit.is_selected = false
	_unit_path.stop()
	_unit_overlay.clear()


func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()


func _move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	
	_deselect_unit()
	
	_active_unit.walk_along(_unit_path._current_path)
	yield(_active_unit, "walk_finished")
	_clear_active_unit()


func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)


func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		_move_active_unit(cell)
