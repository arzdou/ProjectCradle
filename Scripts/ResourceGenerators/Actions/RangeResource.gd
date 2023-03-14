extends Resource
class_name RangeResource

@export var type = CONSTANTS.WEAPON_RANGE_TYPES.RANGE # (CONSTANTS.WEAPON_RANGE_TYPES)
@export var range_value: int = 10
@export var blast: int = 0


# Returns a dictionary with the cells that could be and are affected by an attack
func get_cells_in_range(origin_cell: Vector2, target_cell: Vector2) -> Dictionary:
	var out: Dictionary = {
		"in_range": [],
		"damaged": []
	}
	
	var angle = origin_cell.angle_to_point(target_cell)
	
	out["in_range"] = GlobalGrid.line_of_sight(origin_cell, range_value)
	match type:
		CONSTANTS.WEAPON_RANGE_TYPES.RANGE:
			out["damaged"] = [target_cell]
			
		CONSTANTS.WEAPON_RANGE_TYPES.LINE:
			out["damaged"] = GlobalGrid.ray_cast_from_cell(origin_cell, angle, range_value)

		CONSTANTS.WEAPON_RANGE_TYPES.CONE:
			out["damaged"] = GlobalGrid.cone_from_cell(origin_cell, angle, range_value)

		CONSTANTS.WEAPON_RANGE_TYPES.BLAST:
			out["in_range"] = GlobalGrid.line_of_sight(origin_cell, blast)
			out["damaged"] = GlobalGrid.line_of_sight(target_cell, blast)

		CONSTANTS.WEAPON_RANGE_TYPES.BURST:
			out["in_range"] = GlobalGrid.line_of_sight(origin_cell, blast)
			out["damaged"] = GlobalGrid.line_of_sight(origin_cell, blast)

		CONSTANTS.WEAPON_RANGE_TYPES.THREAT:
			out["damaged"] = [target_cell]

	return out
