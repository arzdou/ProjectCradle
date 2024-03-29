extends Marker2D
class_name MouseCamera

signal camera_moved(mode, new_position)

var zoom_min := 1.0
var zoom_max: float

var _cursor_in_menu := false

@onready var camera_2d = $Camera2D
@onready var timer = $Timer

func _ready():
	if not timer:
		await timer.ready
	set_as_top_level(true)
	update_camera_limits()


func _process(_delta):
	if _cursor_in_menu:
		return
	
	var cursor_position: Vector2 = get_global_mouse_position()
	move_camera_based_on_cursor(cursor_position, 'mouse')


func _unhandled_input(event):
	
	if event.is_action("mouse_down"):
		set_camera_zoom(camera_2d.zoom.x + 1)
	elif event.is_action("mouse_up"):
		set_camera_zoom(camera_2d.zoom.x - 1)


func get_camera_size() -> Vector2:
	var vtrans = camera_2d.get_canvas_transform()
	var vsize = get_viewport_rect().size
	return vsize/vtrans.get_scale()


func _get_camera_center() -> Vector2:
	var vtrans = camera_2d.get_canvas_transform()
	var top_left = -vtrans.get_origin() / vtrans.get_scale()
	return top_left + 0.5*get_camera_size()


func update_camera_limits():
	camera_2d.limit_left = 0
	camera_2d.limit_top = 0
	camera_2d.limit_right = GlobalGrid.size.x * GlobalGrid.cell_size.x
	camera_2d.limit_bottom = GlobalGrid.size.y * GlobalGrid.cell_size.y
	position = _get_camera_center()
	
	zoom_max = min(
		(GlobalGrid.size.x * GlobalGrid.cell_size.x) / get_camera_size().x,
		(GlobalGrid.size.x * GlobalGrid.cell_size.x) / get_camera_size().y
	)


func set_camera_zoom(new_zoom: float):
	if not timer.is_stopped():
		return
	
	new_zoom = clamp(floor(new_zoom), zoom_min, zoom_max)
	
	if new_zoom == camera_2d.zoom.x:
		return
	
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(camera_2d, "zoom", Vector2(new_zoom, new_zoom), timer.wait_time*0.5)
	timer.start()

func set_camera_position(new_position_x: float, new_position_y: float, mode: String) -> void:
	# Clamp the position of the camera between the edges of the map and send a 
	# signal if the position was changed
	
	var new_position = Vector2.ZERO
	new_position.x = clamp(
		new_position_x, 
		camera_2d.limit_left + get_camera_size().x/2, 
		camera_2d.limit_right - get_camera_size().x/2
	)
	new_position.y = clamp(
		new_position_y,
		camera_2d.limit_top  + get_camera_size().y/2, 
		camera_2d.limit_bottom - get_camera_size().y/2
	)
	
	if new_position == position:
		return
	var cell_movement: Vector2 = GlobalGrid.local_to_map(new_position-position)

	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "position", new_position, timer.wait_time*0.0)

	
	timer.start()
	emit_signal("camera_moved", mode, cell_movement)


func move_camera_based_on_cursor(cursor_position: Vector2, mode: String) -> void:
	# Scroll the camera based on the position of cursor, be it the mouse or the in-game cursor
	# TODO: Adapt the scroll speed and drag margin depending on the zoom
	if not timer:
		return
		
	if not timer.is_stopped():
		return
	
	var camera_center: Vector2 = _get_camera_center()
	var delta_pos = (cursor_position - camera_center)
	
	var delta_x := 0.0
	if abs(delta_pos.x) > 0.99 * get_camera_size().x / 2:
		delta_x = sign(delta_pos.x) * GlobalGrid.cell_size.x

	var delta_y := 0.0
	if abs(delta_pos.y) > 0.99 * get_camera_size().y / 2:
		delta_y = sign(delta_pos.y) * GlobalGrid.cell_size.y
	
	set_camera_position(position.x + delta_x, position.y + delta_y, mode)


func _on_Cursor_moved(_cursor_mode, cursor_position):
	if not camera_2d: # During the first frames the camera node is not ready
		await $Camera2D.ready
	move_camera_based_on_cursor(cursor_position, 'cursor')

