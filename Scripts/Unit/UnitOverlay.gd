# Draws an overlay over an array of cells.
class_name UnitOverlay
extends TileMap


func draw(cells: Array) -> void:
	clear()
	# We loop over the cells and assign them the only tile available in the tileset, tile 0.
	for cell in cells:
		set_cellv(cell, 0)
