extends Resource
class_name Map

export(Texture) var image
export(Vector2) var size

var overlay_tiles: Dictionary
var units: Dictionary

func _init(
	_image: Texture = null, 
	_size: Vector2 = Vector2(0,0), 
	_overlay_tiles: Dictionary = {}, 
	_units: Dictionary = {}
):
	image = _image
	size = _size
	overlay_tiles = _overlay_tiles
	units = _units
