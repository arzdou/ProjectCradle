class_name UnitPath
extends TileMap

var _pathfinder: PathFinder
export var grid: Resource

var full_path := PoolVector2Array()
var current_path := PoolVector2Array()

onready var unit_manager = $"../../UnitManager"


func initialize(walkable_cells: Array) -> void:
	_pathfinder = PathFinder.new(grid, walkable_cells)
	

func draw(start_cell: Vector2, end_cell: Vector2) -> void:
	clear()
	$BackTileMap.clear()
	if start_cell == end_cell:
		return
	
	full_path = _pathfinder.calculate_point_path(start_cell, end_cell)
	current_path = PoolVector2Array()
		
	# TODO: Move this to UnitPath and change the opacity of the arrow
	# Check for any larger adjacent enemy in the path and stop the movement
	for i in range(full_path.size()):
		var stop_path := false
		var engaged_units = unit_manager.check_possible_engagement(full_path[i])
		current_path.push_back(full_path[i])
		for engaged_unit in engaged_units:
			if engaged_unit._mech.size > unit_manager.active_unit._mech.size:
				stop_path = true 
			
		if stop_path:
			break
	
	for cell in full_path:
		$BackTileMap.set_cellv(cell, 1)
	for cell in current_path:
		set_cellv(cell, 0)
	
	# Enables the autotiling
	update_bitmask_region()
	$BackTileMap.update_bitmask_region()
	
func stop() -> void:
	_pathfinder = null
	current_path = PoolVector2Array()
	clear()
	$BackTileMap.clear()
