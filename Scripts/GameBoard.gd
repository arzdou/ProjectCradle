class_name GameBoard
extends YSort

export var _grid: Resource = preload("res://Resources/Grid.tres")

var _directions = _grid.directions()
var _units := {}
var _active_unit: Unit
var _walkable_cells := []

onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _unit_path: UnitPath = $UnitPath 
onready var _cursor = $Cursor

func _ready() -> void:
	_reinitialize()


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
	
	if _units[cell].ally_or_enemy == 'enemy':
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
	
	if new_cell == _active_unit.cell:
		_deselect_unit()
		_clear_active_unit()
	
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	
	_deselect_unit()
	
	_active_unit.walk_along(_unit_path._current_path)
	yield(_active_unit, "walk_finished")
	_select_unit_action(_active_unit)
	_clear_active_unit()


func _select_unit_action(unit: Unit) -> void:
	# Deactivate cursor and show action menu until an action has been taken
	unit.is_selecting_action = true
	_cursor.is_active = false
	var weapon = yield(unit, "action_selected")
	unit.is_selecting_action = false
	_cursor.is_active = true

func apply_damage(recieving_unit: Unit, damage: int) -> void:
	recieving_unit.take_damage(damage)


func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)
	
	if not _active_unit:
		for cell in _units:
			pass
			_units[cell].hide_hud()
			_units[cell].hide_action_menu()
	
	if _units.has(new_cell):
		_units[new_cell].show_hud()
		_units[new_cell].hide_action_menu()

func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		_move_active_unit(cell)

