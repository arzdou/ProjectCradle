class_name PathFinder
extends Resource

# The script is used to initialize this class correctly
var _astar := AStar2D.new()
var _directions: Array


func _init(walkable_cells: Array) -> void:
	_directions = GlobalGrid.DIRECTIONS
	
	var _cell_mappings := {}
	for cell in walkable_cells:
		_cell_mappings[cell] = GlobalGrid.as_index(cell)
	_add_and_connect_points(_cell_mappings)


func calculate_point_path(start_point: Vector2, end_point: Vector2) -> PoolVector2Array:
	var start_index: int = GlobalGrid.as_index(start_point)
	var end_index: int = GlobalGrid.as_index(end_point)
	
	if _astar.has_point(start_index) and _astar.has_point(end_index):
		# The AStar2D object then finds the best path between the two indices.
		return _astar.get_point_path(start_index, end_index)
	else:
		return PoolVector2Array()


func _add_and_connect_points(_cell_mappings: Dictionary) -> void:
	for point in _cell_mappings:
		_astar.add_point(_cell_mappings[point], point)
	
	for point in _cell_mappings:
		for neighbor_index in _find_neighbour_indices(point, _cell_mappings):
			_astar.connect_points(_cell_mappings[point], neighbor_index)


func _find_neighbour_indices(point: Vector2, _cell_mappings: Dictionary) -> Array:
	var neighbour_indices := []
	
	for direction in _directions:
		var neighbour: Vector2 = point + direction
		
		# Do not try to add points that are not in the grid
		if not _cell_mappings.has(neighbour):
			continue
		
		#Check that the connection does not exist since it can generate errors
		if not _astar.are_points_connected(_cell_mappings[point], _cell_mappings[neighbour]):
			neighbour_indices.push_back(_cell_mappings[neighbour])
			
	return neighbour_indices
