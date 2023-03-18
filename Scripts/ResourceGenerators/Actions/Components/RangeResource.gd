extends Resource
class_name RangeResource

@export var type = CONSTANTS.WEAPON_RANGE_TYPES.RANGE # (CONSTANTS.WEAPON_RANGE_TYPES)
@export var range_value: int = 10
@export var blast: int = 0


# Returns a dictionary with the cells that could be and are affected by an attack
func get_cells_in_range(origin_cell: Vector2, target_cell: Vector2) -> Dictionary:
	var out := {
		CONSTANTS.UOVERLAY_CELLS.MARKED: [],
		CONSTANTS.UOVERLAY_CELLS.DAMAGE: [],
		CONSTANTS.UOVERLAY_CELLS.MOVEMENT: [],
		CONSTANTS.UOVERLAY_CELLS.ARROW: [],
		CONSTANTS.UOVERLAY_CELLS.ARROW_BACK: []
	}
	
	var angle = origin_cell.angle_to_point(target_cell)
	
	out[CONSTANTS.UOVERLAY_CELLS.MARKED] = GlobalGrid.line_of_sight(origin_cell, range_value)
	match type:
		CONSTANTS.WEAPON_RANGE_TYPES.RANGE:
			out[CONSTANTS.UOVERLAY_CELLS.DAMAGE] = [target_cell]
			
		CONSTANTS.WEAPON_RANGE_TYPES.LINE:
			out[CONSTANTS.UOVERLAY_CELLS.DAMAGE] = GlobalGrid.ray_cast_from_cell(origin_cell, angle, range_value)

		CONSTANTS.WEAPON_RANGE_TYPES.CONE:
			out[CONSTANTS.UOVERLAY_CELLS.DAMAGE] = GlobalGrid.cone_from_cell(origin_cell, angle, range_value)

		CONSTANTS.WEAPON_RANGE_TYPES.BLAST:
			out["in_range"] = GlobalGrid.line_of_sight(origin_cell, blast)
			out[CONSTANTS.UOVERLAY_CELLS.DAMAGE] = GlobalGrid.line_of_sight(target_cell, blast)

		CONSTANTS.WEAPON_RANGE_TYPES.BURST:
			out[CONSTANTS.UOVERLAY_CELLS.MARKED] = GlobalGrid.line_of_sight(origin_cell, blast)
			out[CONSTANTS.UOVERLAY_CELLS.DAMAGE] = GlobalGrid.line_of_sight(origin_cell, blast)

		CONSTANTS.WEAPON_RANGE_TYPES.THREAT:
			out[CONSTANTS.UOVERLAY_CELLS.DAMAGE] = [target_cell]

	return out
