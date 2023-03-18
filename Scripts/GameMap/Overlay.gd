# Draws an overlay over an array of cells.
class_name Overlay
extends TileMap

enum TILE_TYPE {UNIT, TERRAIN}
@export var tile_type : TILE_TYPE


func draw(terrain_dictionary: Dictionary) -> void:
	clear()
	# We loop over the cells and assign them the only tile available in the tileset, tile 0.
	for key in terrain_dictionary:
		var type 
		match tile_type:
			TILE_TYPE.UNIT:
				type = get_unit_tile_type(key)
			TILE_TYPE.TERRAIN:
				type = get_terrain_tile_type(key)
		
		var tiles = terrain_dictionary[key]
		if type.path:
			set_cells_terrain_path(type.layer, tiles, 0, 0)
			return
			
		for cell in tiles:
			set_cell(
				type.layer, cell, type.source, Vector2i(0,0), type.alt
			)
			

# Get the tile index and alt value for the given constant overlay value
func get_unit_tile_type(value: CONSTANTS.UOVERLAY_CELLS) -> Dictionary:
	var out = {"layer": 0, "source": 0, "alt": 0, "path": false}
	match value:
		CONSTANTS.UOVERLAY_CELLS.MOVEMENT:
			out.alt = 1
		CONSTANTS.UOVERLAY_CELLS.MARKED:
			out.alt = 2
		CONSTANTS.UOVERLAY_CELLS.DAMAGE:
			out.alt = 3
		
		CONSTANTS.UOVERLAY_CELLS.ARROW:
			out.path = true
			out.layer = 1
			out.source = 1
		CONSTANTS.UOVERLAY_CELLS.ARROW_BACK:
			out.path = true
			out.layer = 2
			out.source = 1
	return out


func get_terrain_tile_type(value: CONSTANTS.TOVERLAY_CELLS) -> Dictionary:
	var out = {"layer": 0, "source": 0, "alt": 0, "path": false}
	match value:
		CONSTANTS.TOVERLAY_CELLS.BLOCKED:
			out.alt = 4
			out.layer = 1
		CONSTANTS.TOVERLAY_CELLS.SOFT_COVER:
			out.alt = 5
			out.layer = 1
		CONSTANTS.TOVERLAY_CELLS.HARD_COVER:
			out.alt = 6
			out.layer = 1
	return out
