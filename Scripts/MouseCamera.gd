extends Position2D
class_name MouseCamera

signal camera_moved

export var _grid: Resource = preload("res://Resources/Grid.tres")
onready var camera_2d = $Camera2D
onready var _timer = $Timer

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
	print(vsize/vtrans.get_scale())
	return vsize/vtrans.get_scale()


func _get_camera_center() -> Vector2:
	var vtrans = camera_2d.get_canvas_transform()
	var top_left = -vtrans.get_origin() / vtrans.get_scale()
	return top_left + 0.5*_get_camera_size()


func set_camera_position(new_position_x: float, new_position_y: float) -> void:
	position.x = clamp(
		new_position_x, 
		camera_2d.limit_left + _get_camera_size().x/2, 
		camera_2d.limit_right - _get_camera_size().x/2
	)
	position.y = clamp(
		new_position_y,
		camera_2d.limit_top  + _get_camera_size().y/2, 
		camera_2d.limit_bottom - _get_camera_size().y/2
	)
	_timer.start()
	emit_signal("camera_moved")


func _process(delta):
	if not camera_2d:
		return
	
	if not _timer.is_stopped():
		return
		
	var cursor_position: Vector2 = get_global_mouse_position()
	var camera_center: Vector2 = _get_camera_center()
	
	var delta_pos = (cursor_position - camera_center)
	
	if abs(delta_pos.x) > 4 * _grid.cell_size.x: # Tune to the zoom level
		var delta_x: float = sign(delta_pos.x) * _grid.cell_size.x
		set_camera_position(position.x + delta_x, position.y)

	
	if abs(delta_pos.y) > 2 * _grid.cell_size.y: # Tune to the zoom level
		var delta_y: float = sign(delta_pos.y) * _grid.cell_size.y
		set_camera_position(position.x, position.y + delta_y)

