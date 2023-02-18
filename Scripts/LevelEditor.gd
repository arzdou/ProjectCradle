extends TileMap
class_name LevelEditor

onready var _mouse_camera = $MouseCamera
onready var _cursor = $Cursor
onready var _sprite = $Sprite
onready var _side_bar = $CanvasLayer/SideBar
onready var _overlay = $Overlay

var marked_cells: Dictionary
var selected_terrain_id := 0

export var _grid: Resource = preload("res://Resources/Grid.tres")

var map_size: Vector2
var _cursor_in_menu := false

func _ready():
	_reinitialize()


func _reinitialize():
	if _sprite.texture:
		map_size = _sprite.scale * Vector2(_sprite.texture.get_width(), _sprite.texture.get_height())
		_side_bar.is_active = true
	else:
		map_size = _mouse_camera._get_camera_size()
		_side_bar.is_active = false
		
	_sprite.position = map_size/2
	_grid.size = (map_size / cell_size).ceil()
	draw_grid()
	_mouse_camera.update_camera_limits()


func _process(delta):
	# This need to be done manually because the engine is fucking shit and when the cursor enters
	# a child node of a control node it counts also as exiting.
	
	var mouse_is_inside = get_viewport().get_mouse_position().x > _side_bar.rect_position.x
	if mouse_is_inside and not _cursor_in_menu:
		_mouse_camera._cursor_in_menu = true
		_cursor.set_is_active(false)
		_cursor_in_menu = true
		
	elif not mouse_is_inside and _cursor_in_menu:
		_mouse_camera._cursor_in_menu = false
		_cursor.set_is_active(true)
		_cursor_in_menu = false
	


func draw_grid() -> void:
	for i in _grid.size.x:
		for j in _grid.size.y:
			set_cellv(Vector2(i, j), 0)


func _on_Cursor_accept_pressed(cell):
	if _overlay.get_cellv(cell) != selected_terrain_id and selected_terrain_id != 3:
		_overlay.set_cellv(cell, selected_terrain_id)
		marked_cells[cell] = selected_terrain_id
	else:
		_overlay.set_cellv(cell, -1)
		marked_cells.erase(cell)


func _on_SideBar_id_pressed(id):
	selected_terrain_id = id


func _on_HScrollBar_value_changed(value):
	_sprite.scale = Vector2(value, value)
	_mouse_camera.set_camera_zoom(_sprite.scale)
	_reinitialize()


func _on_FileDialog_file_selected(path):
	var texture = load(path)
	_sprite.texture = texture
	var texture_size = Vector2(_sprite.texture.get_width(), _sprite.texture.get_height())
	$CanvasLayer/SideBar/VBoxContainer/HScrollBar.min_value = max(
		_grid.cell_size.x * 15 / texture_size.x,
		_grid.cell_size.y * 15 / texture_size.y
	)
	$CanvasLayer/SideBar/VBoxContainer/HScrollBar.max_value = max(
		_grid.cell_size.x * 50 / texture_size.x,
		_grid.cell_size.y * 50 / texture_size.y
	)
	_reinitialize()


func _on_SaveDialog_file_selected(path):
	var new_map = Map.new(
		_sprite.texture,
		_grid.size,
		marked_cells,
		{}
	)
	ResourceSaver.save(path, new_map)
