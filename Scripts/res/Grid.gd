# Represents a grid with its size, cells and helper functions to transform from indices to coordinates

class_name Grid
extends Resource

export(String, 'square', 'hexagonal') var grid_type = 'square'

export var size := Vector2(20, 20)
export var cell_size := Vector2(80, 80)

const DIRECTION_SQ = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const DIRECTION_HEX = [
	Vector2.LEFT, Vector2.RIGHT,
	Vector2.RIGHT+Vector2.UP, Vector2.RIGHT+Vector2.DOWN,
	Vector2.LEFT+Vector2.UP, Vector2.LEFT+Vector2.DOWN
]


# Useful for center of cell calculations
var _half_cell_size := cell_size / 2


func directions() -> Array:
	if grid_type == "square":
		return DIRECTION_SQ
	elif grid_type == "hexagonal":
		return DIRECTION_HEX
	else:
		return []


# Helper function to transform coordinates to cell index
func map_to_world(map_position: Vector2) -> Vector2:
	return map_position * cell_size + _half_cell_size


# Reverse helper function
func world_to_map(world_position: Vector2) -> Vector2:
	return ( world_position / cell_size ).floor()


# Returns true if the `cell_coordinates` are within the grid.
func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var out := cell_coordinates.x >= 0 and cell_coordinates.x < size.x
	return out and cell_coordinates.y >= 0 and cell_coordinates.y < size.y


# Keep the a position vector within bounds of the grid
func clamp_position(grid_position: Vector2) -> Vector2:
	var out := grid_position
	out.x = clamp(out.x, 0, size.x - 1.0)
	out.y = clamp(out.y, 0, size.y - 1.0)
	return out


# Given Vector2 coordinates, calculates and returns the corresponding integer index. You can use
# this function to convert 2D coordinates to a 1D array's indices.
func as_index(cell: Vector2) -> int:
	return int(cell.x + size.x * cell.y)
