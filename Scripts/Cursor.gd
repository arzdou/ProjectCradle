# Represents a player controlled cursor. Navigates the _grid, selects units, etc.
# Supports both keyboard and mouse (or touch) input.
tool
class_name Cursor
extends Node2D

signal accept_pressed(cell)
signal moved(new_cell)

# grid resource, giving the node access to the _grid size, and more.
export var _grid: Resource = preload("res://Resources/Grid.tres")
# Time before the cursor can move again in seconds.
export var ui_cooldown := 0.1

var is_active := true setget set_is_active
# Coordinates of the current cell the cursor is hovering.
var cell := Vector2.ZERO setget set_cell

onready var _timer: Timer = $Timer
onready var _tween = $Tween


func _ready():
	hide()
	if not _timer:
		yield($Timer, "ready")
	_timer.wait_time = ui_cooldown
	position = _grid.map_to_world(cell)
	set_is_active(is_active)

func _unhandled_input(event):
	# Move the cursor to the mouse position
	if event is InputEventMouseMotion:
		self.cell = _grid.world_to_map(get_global_mouse_position())
		
	elif event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
		emit_signal("accept_pressed", cell)
		get_tree().set_input_as_handled()
		
	var should_move = event.is_pressed()
	# If the player is pressing the key in this frame, we allow the cursor to move. If they keep the
	# keypress down, we only want to move after the cooldown timer stops.
	if event.is_echo():
		should_move = should_move and _timer.is_stopped()

	# And if the cursor shouldn't move, we prevent it from doing so.
	if not should_move:
		return
		
	if event.is_action("ui_right"):
		self.cell += Vector2.RIGHT
	elif event.is_action("ui_up"):
		self.cell += Vector2.UP
	elif event.is_action("ui_left"):
		self.cell += Vector2.LEFT
	elif event.is_action("ui_down"):
		self.cell += Vector2.DOWN
	
	

# We use the draw callback to a rectangular outline the size of a _grid cell, with a width of two
# pixels.
func _draw() -> void:
	# Rect2 is built from the position of the rectangle's top-left corner and its size. To draw the
	# square around the cell, the start position needs to be `-_grid.cell_size / 2`.
	if is_active:
		draw_rect(Rect2(-_grid.cell_size / 2, _grid.cell_size), Color.aliceblue, false, 2.0)


func set_is_active(value: bool) -> void:
	is_active = value
	set_process_unhandled_input(is_active)
	if is_active:
		set_cell(_grid.world_to_map(get_global_mouse_position()), false)
		show()
	else:
		hide()


func set_cell(value: Vector2, do_tween: bool = true) -> void:
	var new_cell = _grid.clamp_position(value)
	
	# Change cell if different from the current one
	if cell.is_equal_approx(new_cell):
		return
	
	cell = new_cell
	if do_tween:
		_tween.interpolate_property(self, 'position', position, _grid.map_to_world(cell), _timer.wait_time*0.5)
		_tween.start()
	else:
		position = _grid.map_to_world(cell)

	emit_signal("moved", cell)
	_timer.start()


func _on_BoardCamera_camera_moved(mode, new_position):
	if mode=='mouse':
		self.cell = _grid.world_to_map(get_global_mouse_position())
