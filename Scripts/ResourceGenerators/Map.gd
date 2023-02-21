extends Resource
class_name Map

export(Texture) var image
export(Vector2) var size
export(Dictionary) var terrain_tiles
export(Dictionary) var units

func _init(
	_image: Texture = null, 
	_size: Vector2 = Vector2(0,0), 
	_terrain_tiles: Dictionary = {}, 
	_units: Dictionary = {}
):
	image = _image
	size = _size
	terrain_tiles = _terrain_tiles
	units = _units
	print(terrain_tiles)
