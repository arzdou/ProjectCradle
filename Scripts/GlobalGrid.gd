# Represents a grid with its size, cells and helper functions to transform from indices to coordinates
extends Node

var cell_size := Vector2(64, 64)

var size := Vector2(50, 32)
var unit_array := []
var terrain_dict := {}

const RAY_CAST_SPEED := 10 # Speed of the ray casting in pixels
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]


func _init():
	pass


func initialize(map_resource: Resource, units: Array) -> void:
	unit_array = units
	terrain_dict = map_resource.terrain_tiles
	size = map_resource.size


# Helper function to transform coordinates to cell index
func map_to_local(map_position: Vector2) -> Vector2:
	return map_position * cell_size + cell_size / 2


# Reverse helper function
func local_to_map(world_position: Vector2) -> Vector2:
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


# Returns all cells that are not traversable
func get_occupied_cells() -> Array:
	var out := []
	for unit in unit_array:
		out.push_back(unit.cell)
	return out


# Finds if there is a unit in a given cell
func in_cell(cell: Vector2) -> Unit:
	for unit in unit_array:
		if unit.cell == cell:
			return unit
	return null



# Flood fill algorithm to calculate vision and movement
func flood_fill(cell: Vector2, move_range: int) -> Array:
	var out := []
	var blocked_cells = terrain_dict[CONSTANTS.EOVERLAY_CELLS.BLOCKED]
	# We use a stack of cells to process, when there are no more we exit
	var stack := [cell]
	
	while not stack.is_empty():
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
		for direction in DIRECTIONS:
			var next_cell: Vector2 = current + direction
			if blocked_cells.has(next_cell):
				continue 
			if next_cell in out:
				continue
			if next_cell.x < 0 or next_cell.y < 0:
				continue
			stack.push_back(next_cell)
			
	return out


# Ray Casting algorithm from an initial cell and angle
func ray_cast_from_cell(cell: Vector2, angle: float, view_range: int) -> Array:
	var out := []
	var blocked_cells = terrain_dict[CONSTANTS.EOVERLAY_CELLS.BLOCKED]
	var ray_cast: Vector2 = map_to_local(cell)
	
	while true:
		ray_cast += Vector2(-cos(angle), -sin(angle)) * RAY_CAST_SPEED
		var ray_cast_cell = local_to_map(ray_cast)
		
		if ray_cast_cell in blocked_cells:
			break
		
		var distance = abs(ray_cast_cell.x - cell.x) +  abs(ray_cast_cell.y - cell.y)
		

		# The algorithm stops when the distance in cells is larger than the range
		if distance - 1 >= view_range:
			break
		elif not out.has(ray_cast_cell):
				out.push_back(ray_cast_cell)
	return out


# Ray casts in a circle around a cell, analogous to a line of sight
func line_of_sight(cell: Vector2, view_range: int) -> Array:
	var out := []
	var min_angle = atan(1/float(view_range)) # Did the math :)
	var number_of_raycast = floor(2*PI / min_angle)
	for i in range(number_of_raycast):
		var ray_cast_angle = ray_cast_from_cell(cell, i*min_angle, view_range)
		for cast_cell in ray_cast_angle:
			if out.has(cast_cell):
				continue
			out.push_back(cast_cell)
	return out


# Create a firing cone from the origin cell. NEEDS REWORK
func cone_from_cell(cell: Vector2, angle: float, view_range: int) -> Array:
	var out := []
	var ANGLE_STEPS = 10
	for i in range(ANGLE_STEPS):
		var cone_angle: float = angle - PI/4 + PI/2 * i / ANGLE_STEPS
		for new_cell in ray_cast_from_cell(cell, cone_angle, view_range):
			if not out.has(new_cell):
				out.push_back(new_cell)
	return out


# Returns an integer value that represents the type of cover a unit in cell 2 has from a unit in cell 1
# 0: no cover, 1: soft cover, 2: hard cover
func find_cover_from_attack(cell_1: Vector2, cell_2: Vector2) -> int:
	var angle: float = cell_1.angle_to_point(cell_2)
	var distance = cell_1.distance_to(cell_2)
	var line_of_sight = ray_cast_from_cell(cell_1, angle, distance)
	
	var hard_cover = terrain_dict[CONSTANTS.EOVERLAY_CELLS.HARD_COVER]
	var soft_cover = terrain_dict[CONSTANTS.EOVERLAY_CELLS.SOFT_COVER]
	
	if hard_cover.has(line_of_sight[-2]):
		return 2
	
	if soft_cover.has(line_of_sight[-2]):
		return 1
		
	for cell in line_of_sight:
		if hard_cover.has(cell):
			return 1
			
	return 0


func sum_int_array(arr: Array) -> int:
	var out: int = 0
	for i in arr:
		out += i
	return out
