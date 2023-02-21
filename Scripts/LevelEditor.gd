extends YSort
class_name LevelEditor

export var _grid: Resource = preload("res://Resources/Grid.tres")

var _cursor_in_menu := false

onready var _game_map = $GameMap
onready var _side_bar = $CanvasLayer/SideBar

func _ready():
	_game_map.drawing_cells = true


func _process(delta):
	# This need to be done manually because the engine is fucking shit and when the cursor enters
	# a child node of a control node it counts also as exiting.

	var mouse_is_inside = get_viewport().get_mouse_position().x > _side_bar.rect_position.x
	if mouse_is_inside and not _cursor_in_menu:
		_game_map._mouse_camera._cursor_in_menu = true
		_game_map.cursor.set_is_active(false)
		_cursor_in_menu = true

	elif not mouse_is_inside and _cursor_in_menu:
		_game_map._mouse_camera._cursor_in_menu = false
		_game_map.cursor.set_is_active(true)
		_cursor_in_menu = false


func _on_SideBar_id_pressed(id):
	_game_map.selected_terrain_id = id


func _on_HScrollBar_value_changed(value):
	$CanvasLayer/SideBar/VBoxContainer/Label.text = "Map Size: x" + String(value)
	_game_map.set_scale(Vector2(value, value))


func _on_FileDialog_file_selected(path):
	# Loads the image given by the path and sets the zoom limits based on the size
	var texture = load(path)
	_game_map.initialize(texture)
	var texture_size = Vector2(_game_map._sprite.texture.get_width(), _game_map._sprite.texture.get_height())
	$CanvasLayer/SideBar/VBoxContainer/HScrollBar.min_value = max(
		_grid.cell_size.x * 15 / texture_size.x,
		_grid.cell_size.y * 15 / texture_size.y
	)
	$CanvasLayer/SideBar/VBoxContainer/HScrollBar.max_value = max(
		_grid.cell_size.x * 50 / texture_size.x,
		_grid.cell_size.y * 50 / texture_size.y
	)
	_side_bar.is_active = true


func _on_SaveDialog_file_selected(path):
	var new_map = Map.new(
		_game_map._sprite.texture,
		_grid.size,
		_game_map.terrain_tiles,
		{}
	)
	ResourceSaver.save(path, new_map)
