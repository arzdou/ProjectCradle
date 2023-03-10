class_name UnitPath
extends TileMap

var _pathfinder: PathFinder
@export var grid: Resource

var full_path := PackedVector2Array()
var current_path := PackedVector2Array()

@onready var unit_manager = $"../../UnitManager"


func initialize(walkable_cells: Array) -> void:
	_pathfinder = PathFinder.new(walkable_cells)
	

func draw(start_cell: Vector2, end_cell: Vector2) -> void:
	clear()
	if start_cell == end_cell:
		return
	
	full_path = _pathfinder.calculate_point_path(start_cell, end_cell)
	current_path = PackedVector2Array()
		
	# Check for any larger adjacent enemy in the path and stop the movement
	for i in range(full_path.size()):
		var stop_path := false
		var engaged_units = unit_manager.get_neighbours(full_path[i])
		current_path.push_back(full_path[i])
		for engaged_unit in engaged_units:
			if engaged_unit == unit_manager.active_unit:
				continue
			elif engaged_unit._mech.size > unit_manager.active_unit._mech.size:
				stop_path = true 
			
		if stop_path:
			break
	
	#Set the paths in each layer. 1 has a modulation of the transparency
	set_cells_terrain_path(1, full_path, 0, 0)
	set_cells_terrain_path(0, current_path, 0, 0)
	
func stop() -> void:
	_pathfinder = null
	current_path = PackedVector2Array()
	clear()
