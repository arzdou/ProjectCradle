# Draws an overlay over an array of cells.
class_name UnitOverlay
extends TileMap

func draw(cell_dictionary: Dictionary) -> void:
	clear()
	# We loop over the cells and assign them the only tile available in the tileset, tile 0.
	for cell in cell_dictionary:
		set_cellv(cell, cell_dictionary[cell])
