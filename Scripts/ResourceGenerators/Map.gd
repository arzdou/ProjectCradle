extends Resource
class_name Map

export(Texture) var image
export(Vector2) var size

var marked_cells: Dictionary
var units: Dictionary

func _init(
	_image: Texture = null, 
	_size: Vector2 = Vector2(0,0), 
	_marked_cells: Dictionary = {}, 
	_units: Dictionary = {}
):
	image = _image
	size = _size
	marked_cells = _marked_cells
	units = _units
