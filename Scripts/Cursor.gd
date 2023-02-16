# Represents a player controlled cursor. Navigates the grid, selects units, etc.
# Supports both keyboard and mouse (or touch) input.
tool
class_name Cursor
extends Node2D

signal accept_pressed(cell)
signal moved(new_cell)

# Grid resource, giving the node access to the grid size, and more.
export var grid: Resource = preload("res://Resources/Grid.tres")
# Time before the cursor can move again in seconds.
export var ui_cooldown := 0.1

var is_active := true setget set_is_active
# Coordinates of the current cell the cursor is hovering.
var cell := Vector2.ZERO setget set_cell

onready var _timer: Timer = $Timer


func _ready():
	hide()
	_timer.wait_time = ui_cooldown
	position = grid.map_to_world(cell)
	set_is_active(is_active)


func _unhandled_input(event):
	# Move the cursor to the mouse position
	if event is InputEventMouseMotion:
		self.cell = grid.world_to_map(get_global_mouse_position())
		
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
	
	

# We use the draw callback to a rectangular outline the size of a grid cell, with a width of two
# pixels.
func _draw() -> void:
	# Rect2 is built from the position of the rectangle's top-left corner and its size. To draw the
	# square around the cell, the start position needs to be `-grid.cell_size / 2`.
	if is_active:
		draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), Color.aliceblue, false, 2.0)


func set_is_active(value: bool) -> void:
	is_active = value
	set_process_unhandled_input(is_active)
	if is_active:
		show()
		set_cell(grid.world_to_map(get_viewport().get_mouse_position()))
	else:
		hide()


func set_cell(value: Vector2) -> void:
	var new_cell = grid.clamp_position(value)
	
	# Change cell if different from the current one
	if cell.is_equal_approx(new_cell):
		return
	cell = new_cell
	
	position = grid.map_to_world(cell)
	emit_signal("moved", cell)
	_timer.start()
