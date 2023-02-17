extends Position2D
class_name MouseCamera

signal camera_moved(mode, cell_movement)

export var _grid: Resource = preload("res://Resources/Grid.tres")
onready var camera_2d = $Camera2D
onready var _timer = $Timer
onready var _tween = $Tween

func _ready():
	set_as_toplevel(true)
	camera_2d.limit_left = 0
	camera_2d.limit_top = 0
	camera_2d.limit_right = _grid.size.x * _grid.cell_size.x
	camera_2d.limit_bottom = _grid.size.y * _grid.cell_size.y
	
	position = _get_camera_center()


func _get_camera_size() -> Vector2:
	var vtrans = camera_2d.get_canvas_transform()
	var vsize = get_viewport_rect().size
	return vsize/vtrans.get_scale()


func _get_camera_center() -> Vector2:
	var vtrans = camera_2d.get_canvas_transform()
	var top_left = -vtrans.get_origin() / vtrans.get_scale()
	return top_left + 0.5*_get_camera_size()


func set_camera_position(new_position_x: float, new_position_y: float, mode: String) -> void:
	# Clamp the position of the camera between the edges of the map and send a 
	# signal if the position was changed
	
	var new_position = Vector2.ZERO
	new_position.x = clamp(
		new_position_x, 
		camera_2d.limit_left + _get_camera_size().x/2, 
		camera_2d.limit_right - _get_camera_size().x/2
	)
	new_position.y = clamp(
		new_position_y,
		camera_2d.limit_top  + _get_camera_size().y/2, 
		camera_2d.limit_bottom - _get_camera_size().y/2
	)
	
	if new_position == position:
		return
	var cell_movement: Vector2 = _grid.world_to_map(new_position-position)
	_tween.interpolate_property(self, "position", position, new_position, _timer.wait_time*0.5)
	_tween.start()
	
	_timer.start()
	emit_signal("camera_moved", mode, cell_movement)


func move_camera_based_on_cursor(cursor_position: Vector2, mode: String) -> void:
	# Scroll the camera based on the position of cursor, be it the mouse or the in-game cursor
	# TODO: Adapt the scroll speed and drag margin depending on the zoom
	
	if not _timer.is_stopped():
		return
	
	var camera_center: Vector2 = _get_camera_center()
	var delta_pos = (cursor_position - camera_center)
	
	var delta_x := 0.0
	if abs(delta_pos.x) > 4 * _grid.cell_size.x: # Tune to the zoom level
		delta_x = sign(delta_pos.x) * _grid.cell_size.x

	var delta_y := 0.0
	if abs(delta_pos.y) > 2 * _grid.cell_size.y: # Tune to the zoom level
		delta_y = sign(delta_pos.y) * _grid.cell_size.y
	
	set_camera_position(position.x + delta_x, position.y + delta_y, mode)


func _process(delta):
	var cursor_position: Vector2 = get_global_mouse_position()
	move_camera_based_on_cursor(cursor_position, 'mouse')


func _on_Cursor_moved(new_cell):
	if not camera_2d:
		return
		
	var cursor_position: Vector2 = _grid.map_to_world(new_cell)
	move_camera_based_on_cursor(cursor_position, 'cursor')
