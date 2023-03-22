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



func process(active_unit: Unit, target_cell: Vector2) -> ResolvedAction:
	var path = get_cells_in_range(active_unit, target_cell)[CONSTANTS.UOVERLAY_CELLS.ARROW]
	var out : ResolvedAction = resolved_action.new(self, active_unit, target_cell)
	
	if path[-1] == active_unit.cell:
		return out
		
	out.add_movement(active_unit, path, move_range_type)
	return out


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
