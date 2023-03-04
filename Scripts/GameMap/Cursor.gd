# Represents a player controlled cursor. Navigates the GameMap, selects units, etc.
# Supports both keyboard and mouse (or touch) input.
class_name Cursor
extends Node2D

signal accept_pressed(cell)
signal moved(new_cell)

enum CURSOR_MODE {KEY, MOUSE}
const MOVEMENT_TOLERANCE := 1.0
const MOUSE_OFFSET := Vector2(-20,20)

@export var ui_cooldown := 0.1 # Time before the cursor can move again in seconds.
@export var mode: CURSOR_MODE

var _has_mouse_recently_moved := true
var is_active := true : set = set_is_active
var cell := Vector2.ZERO : set = set_cell # Coordinates of the current cell the cursor is hovering.

@onready var timer: Timer = $Timer
@onready var _arrow: Sprite2D = $Arrow
@onready var _highlight:Sprite2D = $Highlight


func _ready():
	hide()
	if not timer:
		await $Timer.ready
	timer.wait_time = ui_cooldown
	set_is_active(is_active)


func _process(_delta):
	if not is_active:
		return
	
	var current_mouse_position: Vector2 = get_global_mouse_position()

	mode = CURSOR_MODE.MOUSE
	_arrow.position = current_mouse_position - MOUSE_OFFSET
	self.cell = GlobalGrid.local_to_map(current_mouse_position)
	_has_mouse_recently_moved = false

func _unhandled_input(event):
	# Move the cursor to the mouse position
	
	if event is InputEventMouseMotion:
		_has_mouse_recently_moved = true

	if event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
		emit_signal("accept_pressed", cell)
		get_viewport().set_input_as_handled()
		
	var should_move = event.is_pressed()
	# If the player is pressing the key in this frame, we allow the cursor to move. If they keep the
	# keypress down, we only want to move after the cooldown timer stops.
	if event.is_echo():
		should_move = should_move and timer.is_stopped()

	# And if the cursor shouldn't move, we prevent it from doing so.
	if not should_move:
		return
		
	if event.is_action("ui_right"):
		mode = CURSOR_MODE.KEY
		self.cell += Vector2.RIGHT
	elif event.is_action("ui_up"):
		mode = CURSOR_MODE.KEY
		self.cell += Vector2.UP
	elif event.is_action("ui_left"):
		mode = CURSOR_MODE.KEY
		self.cell += Vector2.LEFT
	elif event.is_action("ui_down"):
		mode = CURSOR_MODE.KEY
		self.cell += Vector2.DOWN


func set_is_active(value: bool) -> void:
	# If the cursor is inactive it will disapear and not handle any action
	if is_active == value:
		pass#return

	is_active = value
	set_process_unhandled_input(is_active)
	set_process(is_active)
	if is_active:
		set_cell(GlobalGrid.local_to_map(get_global_mouse_position()))
		show()
	else:
		hide()


func set_cell(value: Vector2) -> void:
	var new_cell = GlobalGrid.clamp_position(value)
	
	# Change cell if different from the current one
	if cell.is_equal_approx(new_cell):
		return
	
	cell = new_cell
	var new_highlight_pos = GlobalGrid.map_to_local(cell)
	var new_cursor_pos = GlobalGrid.map_to_local(cell) + Vector2(GlobalGrid.cell_size.x, -GlobalGrid.cell_size.y)/2 - MOUSE_OFFSET
	if false:
		var tween = create_tween()
		tween.tween_property(
			_highlight, 'position', new_highlight_pos, timer.wait_time*0.5
		)
		if mode == CURSOR_MODE.KEY:
			tween.tween_property(
				_arrow, 'position', new_cursor_pos, timer.wait_time*0.5
			)
	else:
		_highlight.position = new_highlight_pos
		if mode == CURSOR_MODE.KEY:
			_arrow.position = new_cursor_pos
	
	match mode:
		CURSOR_MODE.MOUSE:
			emit_signal("moved", "mouse", get_global_mouse_position())
		CURSOR_MODE.KEY:
			emit_signal("moved", "cursor", GlobalGrid.map_to_local(cell))

	timer.start()


func _on_BoardCamera_camera_moved(camera_mode, _cell_movement):
	if camera_mode == "mouse":
		_arrow.position = get_global_mouse_position() - MOUSE_OFFSET
		set_cell(cell)
		
