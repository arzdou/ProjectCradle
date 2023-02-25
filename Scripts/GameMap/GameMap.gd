extends TileMap
class_name GameMap

onready var cursor = $Cursor
onready var _mouse_camera = $MouseCamera
onready var _sprite = $Sprite
onready var _overlay = $TerrainOverlay


var selected_terrain_id := 0
var drawing_cells := false
var terrain_tiles := {} setget _set_terrain_tiles

export var _grid: Resource = preload("res://Resources/Grid.tres")

var map_size: Vector2
var ui_timer := 0.1 # seconds

func _ready():
	if not cursor:
		yield($Cursor, "ready")
	cursor.timer.wait_time = ui_timer
	
	if not _mouse_camera:
		yield($MouseCamera, "ready")
	_mouse_camera.timer.wait_time = ui_timer
	
	for terrain in CONSTANTS.EOVERLAY_CELLS.values():
		terrain_tiles[terrain] = []
	
	initialize()


func initialize(texture: Texture = null) -> void:
	_sprite.texture = texture
	if _sprite.texture:
		map_size = _sprite.scale * Vector2(_sprite.texture.get_width(), _sprite.texture.get_height())
		_grid.size = (map_size / cell_size).ceil() - Vector2.ONE
	else:
		map_size = _mouse_camera.get_camera_size() 
		_grid.size = (map_size / cell_size).ceil() + Vector2.ONE*500
		
	_sprite.position = map_size/2
	_mouse_camera.update_camera_limits()
	cursor.is_active = true
	draw_grid()


func set_scale(texture_scale: Vector2) -> void:
	var scale_ratio = texture_scale / _sprite.scale 
	_sprite.scale = texture_scale
	initialize(_sprite.texture)
	var new_camera_position = _mouse_camera.position * scale_ratio
	_mouse_camera.set_camera_position(new_camera_position.x, new_camera_position.y, "scale") 
	_mouse_camera.set_camera_zoom(texture_scale.x)


func draw_grid() -> void:
	clear()
	for i in _grid.size.x:
		for j in _grid.size.y:
			set_cellv(Vector2(i, j), 0)


func _set_terrain_tiles(value: Dictionary) -> void:
	# The input dictionary should have the following structure
	# value = {
	#	[cell: Vector2] = index: int,
	#	...
	# }
	# TODO: Add a check for the structure of the Dict, add an enum in CONSTANTS
	terrain_tiles = value
	_overlay.draw(terrain_tiles) # The draw function already handles clearing


func get_cover() -> Dictionary:
	var cover = {
		"hard": terrain_tiles[CONSTANTS.EOVERLAY_CELLS.HARD_COVER], 
		"soft": terrain_tiles[CONSTANTS.EOVERLAY_CELLS.SOFT_COVER]
		}
	return cover

func _on_Cursor_accept_pressed(cell):
	if not drawing_cells:
		return
		
	if _overlay.get_cellv(cell) != selected_terrain_id and selected_terrain_id != 3:
		terrain_tiles[selected_terrain_id].push_back(cell)
		_set_terrain_tiles(terrain_tiles)
	else:
		for terrain in terrain_tiles:
			terrain_tiles[terrain].erase(cell)
		_set_terrain_tiles(terrain_tiles)


