# This node will be in charge of the map with the following responsabilities

# 1. Manage the tileset of the map
# 2. Manage the terrain type
# 3. Unit overlay, arrow paths and cursor drawing

extends TileMap
class_name GameMap

var is_cursor_active := false setget _set_is_cursor_active
var overlay_tiles = {} setget _set_overlay_tiles
var cursor_cell := Vector2.ZERO setget _set_cursor_cell, _get_cursor_cell

onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _cursor: Cursor = $Cursor
onready var _sprite = $Sprite


func initialize(map):
	_sprite.texture = map.image
	var map_size = _sprite.scale * Vector2(_sprite.texture.get_width(), _sprite.texture.get_height())
	_sprite.position = map_size/2


func initialize_path(cells: Array) -> void:
	_unit_path.initialize(cells)
	
	
func stop_path() -> void:
	_unit_path.stop()


func _set_is_cursor_active(value: bool) -> void:
	if _cursor.is_active == value:
		return
	_cursor.is_active = value


func _set_overlay_tiles(value) -> void:
	# Maybe some checks here for the shape of value would be nice
	
	if not value:
		overlay_tiles = {}
		_unit_overlay.clear()
		_unit_path.stop()
		return
	
	if typeof(value) == TYPE_DICTIONARY:
		overlay_tiles = value
	elif typeof(value) == TYPE_ARRAY:
		overlay_tiles = {0: value}
	
	_unit_overlay.draw(overlay_tiles) # The draw function already handles clearing
	_unit_path.initialize(overlay_tiles[0]) # This might be super sketchy


func _set_cursor_cell(value: Vector2) -> void:
	# Some clamping here would be nice
	_cursor.cell = value


func _get_cursor_cell() -> Vector2:
	return _cursor.cell


func draw_path(start: Vector2, end: Vector2) -> void:
	_unit_path.draw(start, end)


func get_current_path() -> PoolVector2Array:
	return _unit_path.current_path

