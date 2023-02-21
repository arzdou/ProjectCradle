class_name GameBoard
extends YSort

export var _grid: Resource = preload("res://Resources/Grid.tres")
var CONSTANTS: Resource = preload("res://Resources/CONSTANTS.tres")
export(Resource) var map_res = preload("res://Resources/Maps/test.tres")

var _unit_data := [
	{
		'pilot': "res://Resources/Pilots/BasePilot.tres",
		'mech': "res://Resources/Frames/Everest.tres",
		'cell': Vector2(2, 3),
		'team': 'ally'
	},
	{
		'pilot': "res://Resources/Pilots/BasePilot.tres",
		'mech': "res://Resources/Frames/Everest.tres",
		'cell': Vector2(2, 5),
		'team': 'enemy'
	}
]



# Array to store the different identifiers for the sides the unit belong in the map
var teams := ['ally', 'enemy']
var team_turn_index = 0

enum STATE {FREE, MOVEMENT, SELECTING, ACTING}
var _board_state: int = STATE.FREE setget change_state

onready var _game_map = $GameMap
onready var _action_processor = $ActionProcessor
onready var _unit_manager = $UnitManager
onready var _unit_path = $GameMap/UnitPath
onready var _unit_overlay = $GameMap/UnitOverlay

func _ready() -> void:
	if not _game_map:
		yield(_game_map, "ready")
	_game_map.cursor.connect("accept_pressed", self, "_on_Cursor_accept_pressed")
	_game_map.cursor.connect("moved", self, "_on_Cursor_moved")
	
	_game_map.initialize(map_res.image)

	_game_map.terrain_tiles = map_res.terrain_tiles
	_reinitialize()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # It handles well all states
		change_state(STATE.FREE)


func _reinitialize() -> void:
	change_state(STATE.FREE)
	_unit_manager.initialize(_unit_data)
	_unit_manager.update_hud(Vector2(-1,-1))


func get_blocked_cells() -> Array:
	return _unit_manager.get_occupied_cells() + _game_map.get_blocked_terrain()

func get_walkable_cells() -> Array:
	return _grid.flood_fill(_unit_manager.active_unit.cell, _unit_manager.active_unit.move_range, get_blocked_cells())


func _array_to_zero_dict(value: Array) -> Dictionary:
	var out := {}
	for key in value:
		out[key] = 0
	return out


func _select_unit(cell: Vector2) -> void:
	
	var was_unit_selected: bool
	was_unit_selected = _unit_manager.try_selecting_unit(cell, 'ally')
	
	if not was_unit_selected:
		return
	
	if _unit_manager.get_active_move_range() == 0:
		change_state(STATE.SELECTING)
		return
	
	change_state(STATE.MOVEMENT)


func _move_active_unit(new_cell: Vector2) -> void:
	
	var movement_complete
	
	movement_complete = _unit_manager.move_active_unit(
		new_cell, _unit_path.current_path
	)
	
	# This creates problems since movement_complete is not a bool but a yield object, I dunno how to fix it but its ugly af
	if movement_complete:
		change_state(STATE.SELECTING)


# Maybe I could implement a state machine since I have already separated the code...
func change_state(new_state: int) -> void:
	match new_state:
		STATE.FREE:
			_game_map.cursor.is_active = true
			_unit_overlay.draw({})
			_unit_path.stop()
			
			_unit_manager.deselect_unit()
			
		STATE.MOVEMENT:
			_game_map.cursor.is_active = true
			var walkable_cells = get_walkable_cells()
			_unit_overlay.draw(_array_to_zero_dict(walkable_cells))
			_unit_path.initialize(walkable_cells)
			
			_unit_manager.show_side_menu(false)
			
		STATE.SELECTING:
			if _unit_manager.active_unit._is_walking:
				yield(_unit_manager.active_unit, "walk_finished")
			_game_map.cursor.is_active = false
			_unit_overlay.draw({})
			_unit_path.stop()
			_unit_manager.show_side_menu(true) # Toggles the menu and animations of active unit
			
		STATE.ACTING:
			_game_map.cursor.is_active = true
			_unit_overlay.draw({})
			_unit_path.stop()
			
			_unit_manager.show_side_menu(false)
			
		_:
			print('The state you are entering does not exist, the program will probably crash soon')
	
	$HUD/DEBUG_LABEL.text = teams[team_turn_index]
	_board_state = new_state


func finish_unit_turn() -> void:
	_unit_manager.finish_turn()
	change_state(STATE.FREE)
	team_turn_index = (team_turn_index+1) % teams.size()


func _on_Cursor_moved(_mode: String, new_pos: Vector2) -> void:
	var new_cell = _grid.world_to_map(new_pos)
	if _board_state == STATE.MOVEMENT:
		_unit_path.draw(_unit_manager.active_unit.cell, new_cell)
		
	elif _board_state == STATE.ACTING:
		_action_processor.process_action_targeted(new_cell, false)
		_unit_overlay.draw(_array_to_zero_dict(_action_processor.marked_cells))
	
	if _unit_manager:
		_unit_manager.update_hud(new_cell)

func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if _board_state == STATE.FREE:
		_select_unit(cell)
		
	elif _board_state == STATE.MOVEMENT:
		_move_active_unit(cell)
		
	elif _board_state == STATE.ACTING:
	
		var was_action_performed: bool = _action_processor.process_action_targeted(cell, true)
			# Finish the unit action
		if was_action_performed:
			finish_unit_turn()

func _on_Unit_action_selected(action) -> void:
	change_state(STATE.ACTING)
	
	_action_processor.initialize(action, _game_map.get_blocked_terrain())
	var pos = _grid.map_to_world(_game_map.cursor.cell)
	_on_Cursor_moved('', pos)

