class_name UnitPath
extends TileMap

var _pathfinder: PathFinder
export var grid: Resource

var _current_path := PoolVector2Array()


func initialize(walkable_cells: Array) -> void:
	_pathfinder = PathFinder.new(grid, walkable_cells)
	

func draw(start_cell: Vector2, end_cell: Vector2) -> void:
	clear()
	if start_cell == end_cell:
		return
	
	_current_path = _pathfinder.calculate_point_path(start_cell, end_cell)
	for cell in _current_path:
		set_cellv(cell, 0)
	
	# Enables the autotiling
	update_bitmask_region()

func stop() -> void:
	_pathfinder = null
	clear()
