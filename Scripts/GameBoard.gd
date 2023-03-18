class_name GameBoard
extends Node2D

signal unit_selected(unit)
signal unit_cleared

const CONSTANTS: Resource = preload("res://Resources/CONSTANTS.tres")
@export var map_res: Resource = preload("res://Resources/Maps/test.tres")



var _unit_data := [
	{
		'pilot': "res://Resources/Pilots/BasePilot.tres",
		'mech': "res://Resources/Frames/Everest.tres",
		'cell': Vector2(6, 3),
		'team': 'ally'
	},
	{
		'pilot': "res://Resources/Pilots/BasePilot.tres",
		'mech': "res://Resources/Frames/Everest.tres",
		'cell': Vector2(4, 6),
		'team': 'enemy'
	}
]



# Array to store the different identifiers for the sides the unit belong in the map
var teams := []
var team_turn_index = 0

# Holds the unit selected before activation of its turn. When a unit is selected 
# the menu is built and an activation button is created
var selected_unit: Unit : set = set_selected_unit

# Holds the selected action that is being processed at the moment
var action_processing: BaseAction

@onready var _game_map = $GameMap
@onready var _unit_manager = $UnitManager
@onready var _unit_overlay = $GameMap/UnitOverlay

func _ready():
	if not _game_map:
		await _game_map.ready
	_game_map.cursor.connect("accept_pressed", _on_Cursor_accept_pressed)
	_game_map.cursor.connect("moved", _on_Cursor_moved)

	_reinitialize()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if not selected_unit:
			return
			
		if not _unit_manager.active_unit:
			set_selected_unit(null)
			return
			
		if action_processing:
			action_processing = null
			_unit_overlay.clear()


func _reinitialize():
	_game_map.initialize(map_res.image)
	_game_map.terrain_tiles = map_res.terrain_tiles
	_unit_manager.initialize(_unit_data)
	_unit_manager.update_hud(Vector2(-1,-1))
	
	for unit in _unit_manager.unit_list:
		if not teams.has(unit.team):
			teams.push_back(unit.team)
	
	GlobalGrid.initialize(map_res, _unit_manager.unit_list)


func set_selected_unit(value: Unit):
	
	if not value:
		selected_unit = null
		emit_signal("unit_cleared")
		return
		
	if value == selected_unit:
		return
		
	selected_unit = value
	emit_signal("unit_selected", selected_unit)


# Deduct the cost from the unit action pool and if no more actions left then finish the turn
func end_action():
	selected_unit.actions_left -= action_processing.cost
	action_processing = null
	_unit_overlay.clear()
	if selected_unit.actions_left <= 0:
		finish_turn()


func action_failed():
	pass


func finish_turn():
	_unit_manager.finish_turn()
	team_turn_index = (team_turn_index+1) % teams.size()
	LogRepeater.write("%s turn"%teams[team_turn_index])
	set_selected_unit(null)


func _on_Cursor_moved(_mode: String, new_pos: Vector2):
	var new_cell = GlobalGrid.local_to_map(new_pos)
	_unit_manager.update_hud(new_cell)
	
	if action_processing:
		# This updates the unit overlay when the user is selecting an action
		var overlay_cells = action_processing.get_cells_in_range(selected_unit, new_cell)
		_unit_overlay.draw(overlay_cells)


func _on_Cursor_accept_pressed(cell: Vector2):
	# No active unit, then select or deselect unit
	if not _unit_manager.active_unit:
		# When a unit is selected the menu related to this unit appears.
		# The unit can only be selected if there is no active unit in the field
		set_selected_unit(GlobalGrid.in_cell(cell))
	
	# If active unit, then we are waiting for the action to be selected
	if not action_processing:
		return
	
	await _unit_manager.process_reactions(action_processing)
	# Try to perform the action at the hovered cell
	var has_acted = await action_processing.try_to_act(selected_unit, cell)
	
	if not has_acted:
		return
		
	end_action()

func _on_unit_activated():
	_unit_manager.active_unit = selected_unit


func _on_action_selected(action):
	action_processing = action
	var overlay_cells = action_processing.get_cells_in_range(
		_unit_manager.active_unit, _game_map.cursor.cell
	)
	_unit_overlay.draw(overlay_cells)

