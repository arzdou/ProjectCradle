# Represents a grid with its size, cells and helper functions to transform from indices to coordinates
class_name Grid
extends Resource

export(String, 'square', 'hexagonal') var grid_type = 'square'

export var size := Vector2(50, 32)
export var cell_size := Vector2(64, 64)

const RAY_CAST_SPEED := 10 # Speed of the ray casting in pixels
const DIRECTION_SQ = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const DIRECTION_HEX = [
	Vector2.LEFT, Vector2.RIGHT,
	Vector2.RIGHT+Vector2.UP, Vector2.RIGHT+Vector2.DOWN,
	Vector2.LEFT+Vector2.UP, Vector2.LEFT+Vector2.DOWN
]


func directions() -> Array:
	if grid_type == "square":
		return DIRECTION_SQ
	elif grid_type == "hexagonal":
		return DIRECTION_HEX
	else:
		return []


# Helper function to transform coordinates to cell index
func map_to_world(map_position: Vector2) -> Vector2:
	return map_position * cell_size + cell_size / 2


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


func flood_fill(cell: Vector2, move_range: int, blocked_cells: Array = []) -> Array:
	# Flood fill algorithm to calculate vision and movement
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
		
		if not is_within_bounds(current):
			continue
		
		out.push_back(current)
		
		# Only add new elements to the stack if:
		# 1. They are not repeated
		# 2. They are not occupied
		for direction in directions():
			var next_cell: Vector2 = current + direction
			if blocked_cells.has(next_cell):
				continue 
			if next_cell in out:
				continue
			if next_cell.x < 0 or next_cell.y < 0:
				continue
			stack.push_back(next_cell)
			
	return out


func ray_cast_from_cell(cell: Vector2, angle: float, view_range: int, blocked_cells: Array) -> Array:
	# Ray Casting algorithm from an initial cell and angle
	var out := []
	var ray_cast: Vector2 = map_to_world(cell)
	while true:
		ray_cast += Vector2(-cos(angle), -sin(angle)) * RAY_CAST_SPEED

		var ray_cast_cell = world_to_map(ray_cast)
		
		if ray_cast_cell in blocked_cells:
			break
		
		var distance = abs(ray_cast_cell.x - cell.x) +  abs(ray_cast_cell.y - cell.y)
		

		# The algorithm stops when the distance in cells is larger than the range
		if distance - 1 >= view_range:
			break
		elif not out.has(ray_cast_cell):
				out.push_back(ray_cast_cell)
	return out


func ray_cast_circular(cell: Vector2, view_range: int, blocked_cells: Array) -> Array:
	var out := []
	var min_angle = atan(1/float(view_range)) # Calculate this mathematically
	print(1/view_range)
	print(min_angle)
	var number_of_raycast = floor(2*PI / min_angle)
	for i in range(number_of_raycast):
		var ray_cast_angle = ray_cast_from_cell(cell, i*min_angle, view_range, blocked_cells)
		for cell in ray_cast_angle:
			if out.has(cell):
				continue
			out.push_back(cell)
	return out
	

func cone_from_cell(cell: Vector2, angle: float, view_range: int, blocked_cells: Array) -> Array:
	# Ray Casting algorithm from an initial cell and angle
	# Needs a rework
	var out := []
	var ANGLE_STEPS = 10
	for i in range(ANGLE_STEPS):
		var cone_angle: float = angle - PI/4 + PI/2 * i / ANGLE_STEPS
		for new_cell in ray_cast_from_cell(cell, cone_angle, view_range, blocked_cells):
			if not out.has(new_cell):
				out.push_back(new_cell)
	return out


# Given Vector2 coordinates, calculates and returns the corresponding integer index. You can use
# this function to convert 2D coordinates to a 1D array's indices.
func as_index(cell: Vector2) -> int:
	return int(cell.x + size.x * cell.y)
