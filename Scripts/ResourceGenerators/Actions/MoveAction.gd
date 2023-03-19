extends BaseAction
class_name MoveAction

@export var is_voluntary: bool
@export var move_range_type: CONSTANTS.MOVE_RANGE_TYPES
@export var move_range_value: int


func get_cells_in_range(active_unit: Unit, target_cell: Vector2) -> Dictionary:
	var move_cells = GlobalGrid.flood_fill(
		active_unit.cell, get_moving_range(active_unit)
	)
	var arrow_cells: Dictionary = GlobalGrid.get_cell_path(
		move_cells, active_unit.cell, target_cell
	)
	var out := {
		CONSTANTS.UOVERLAY_CELLS.MARKED: [],
		CONSTANTS.UOVERLAY_CELLS.DAMAGE: [],
		CONSTANTS.UOVERLAY_CELLS.MOVEMENT: move_cells,
		CONSTANTS.UOVERLAY_CELLS.ARROW: arrow_cells["full_path"],
		CONSTANTS.UOVERLAY_CELLS.ARROW_BACK: arrow_cells["current_path"]
	}
	return out


func try_to_act(active_unit: Unit, target_cell: Vector2) -> bool:
	if not can_act(active_unit, target_cell):
		return false
		
	var path : PackedVector2Array = get_cells_in_range(active_unit, target_cell)[CONSTANTS.UOVERLAY_CELLS.ARROW]
	
	# If the new_cell is the same one as the previous one the movement is directly completed
	if path[-1] == active_unit.cell:
		return true
	
	active_unit.walk_along(path)
	await active_unit.walk_finished
	return true



func can_act(active_unit: Unit, target_cell: Vector2) -> bool:
	var path : PackedVector2Array = get_cells_in_range(active_unit, target_cell)[CONSTANTS.UOVERLAY_CELLS.ARROW]
	if path.is_empty():
		return false
	
	if GlobalGrid.in_cell(path[-1]):
		return false
	
	return true


func get_moving_range(unit: Unit) -> int:
	var n_cells: int
	match move_range_type:
		CONSTANTS.MOVE_RANGE_TYPES.MAX:
			n_cells = unit.move_range
		CONSTANTS.MOVE_RANGE_TYPES.REMAINING:
			n_cells = unit.remaining_move_range
		CONSTANTS.MOVE_RANGE_TYPES.VALUE:
			n_cells = move_range_value
	return n_cells
