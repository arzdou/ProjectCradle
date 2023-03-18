extends TileMap
class_name GameMap

@onready var cursor = $Cursor
@onready var _mouse_camera = $MouseCamera
@onready var _sprite = $Sprite2D
@onready var _overlay = $TerrainOverlay

var selected_terrain_id := 0
var drawing_cells := false
var terrain_tiles := {} : set = _set_terrain_tiles

var map_size: Vector2
var ui_timer := 0.1 # seconds

func _ready():
	if not cursor:
		await $Cursor.ready
	cursor.timer.wait_time = ui_timer
	
	if not _mouse_camera:
		await $MouseCamera.ready
	_mouse_camera.timer.wait_time = ui_timer
	
	for terrain in CONSTANTS.TOVERLAY_CELLS.values():
		terrain_tiles[terrain] = []
	
	initialize()


func initialize(texture: Texture2D = null) -> void:
	_sprite.texture = texture
	if _sprite.texture:
		map_size = _sprite.scale * Vector2(_sprite.texture.get_width(), _sprite.texture.get_height())
		GlobalGrid.size = (map_size / GlobalGrid.cell_size).ceil() - Vector2.ONE
	else:
		map_size = _mouse_camera.get_camera_size() 
		GlobalGrid.size = (map_size / GlobalGrid.cell_size).ceil() + Vector2.ONE
		
	_sprite.position = map_size/2
	_mouse_camera.update_camera_limits()
	cursor.is_active = true
	draw_grid()


func set_map_scale(texture_scale: Vector2) -> void:
	var scale_ratio = texture_scale / _sprite.scale 
	_sprite.scale = texture_scale
	initialize(_sprite.texture)
	var new_camera_position = _mouse_camera.position * scale_ratio
	_mouse_camera.set_camera_position(new_camera_position.x, new_camera_position.y, "scale") 
	_mouse_camera.set_camera_zoom(texture_scale.x)


func draw_grid() -> void:
	clear()
	for i in GlobalGrid.size.x:
		for j in GlobalGrid.size.y:
			set_cell(0, Vector2(i, j), 0, Vector2i(0, 0))


func _set_terrain_tiles(value: Dictionary) -> void:
	# The input dictionary should have the following structure
	# value = {
	#	[cell: Vector2] = index: int,
	#	...
	# }
	# TODO: Add a check for the structure of the Dict, add an enum in CONSTANTS
	terrain_tiles = value
	_overlay.draw(terrain_tiles) # The draw function already handles clearing

func _on_Cursor_accept_pressed(cell):
	if not drawing_cells:
		return
		
	if selected_terrain_id != 0:
		if terrain_tiles[selected_terrain_id-1].has(cell):
			return
		terrain_tiles[selected_terrain_id-1].push_back(cell)
		_set_terrain_tiles(terrain_tiles)
	else:
		for terrain in terrain_tiles:
			terrain_tiles[terrain].erase(cell)
		_set_terrain_tiles(terrain_tiles)


