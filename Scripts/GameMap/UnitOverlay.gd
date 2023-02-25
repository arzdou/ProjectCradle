# Draws an overlay over an array of cells.
class_name UnitOverlay
extends TileMap

func draw(terrain_dictionary: Dictionary) -> void:
	clear()
	# We loop over the cells and assign them the only tile available in the tileset, tile 0.
	for key in terrain_dictionary:
		for cell in terrain_dictionary[key]:
			set_cellv(cell, key)


func draw_array(cell_array: Array, terrain_key: int) -> void:
	clear()
	# We loop over the cells and assign them the only tile available in the tileset, tile 0.
	for cell in cell_array:
		set_cellv(cell, terrain_key)
