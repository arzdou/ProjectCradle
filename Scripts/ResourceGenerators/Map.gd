extends Resource
class_name Map

@export var image: Texture2D
@export var size: Vector2
@export var terrain_tiles: Dictionary
@export var units: Dictionary

func _init(
	_image: Texture2D = null, 
	_size: Vector2 = Vector2(0,0), 
	_terrain_tiles: Dictionary = {}, 
	_units: Dictionary = {}
):
	image = _image
	size = _size
	terrain_tiles = _terrain_tiles
	units = _units
