# Represents a unit in the game board
# The unit manager takes care of instancing the units and controlling them

@tool 
class_name Unit
extends Path2D

signal action_selected(action, mode)
signal walk_finished

var CONSTANTS: Resource = preload("res://Resources/CONSTANTS.tres")

var _pilot: PilotStats
var _mech: Mech

var pilot_name: String = 'PILOT'
var mech_name: String = 'MECH'

# Type of the unit
@export var team: String # (String, 'ally', 'enemy')

# Texture2D representing the unit.
@export var skin: Texture2D : set = set_skin
@export var skin_offset := Vector2.ZERO : set = set_skin_offset

# Through its setter function, the `_is_walking` property toggles processing for this unit.
# See `_set_is_walking()` at the bottom of this code snippet.
var _is_walking := false : set = _set_is_walking
@export var move_range: int # Distance to which the unit can walk in cells.
@export var move_speed := 600.0 # The unit's move speed in pixels, when it's moving along a path.
var remaining_move_range: int = move_range : get = _get_remaining_move_range

# Cell where the unit is located
var cell := Vector2.ZERO : set = set_cell
var is_selected := false : set = set_is_selected

var is_disengaging := false : set = set_is_disengaging
var used_move_range := 0

var actions_left := 2 : set = set_actions_left
var overcharge_charges = 0
var status: Dictionary = {} # Keys will be the status, as given by CONSTANT.STATUS, and values bool.
var conditions: Dictionary = {} # Keys will be the condition, as given by CONSTANT.CONDITIONS, and key the number of remaining turns
var engaged_units: Array[Unit] : set = set_engaged_units

# Preload all components
@onready var _stats = $UnitStats
@onready var _sprite: Sprite2D = $PathFollow2D/Sprite2D
@onready var _path_follow: PathFollow2D = $PathFollow2D
@onready var _anim_player: AnimationPlayer = $AnimationPlayer

@onready var _bar_hud = $PathFollow2D/HUD/Bars
@onready var _status_hud = $PathFollow2D/HUD/StatusHUD


func _ready():
	# _process will only run if the unit needs to move
	set_process(false)
	if not Engine.is_editor_hint():
		# We create the curve resource here because creating it in the editor prevents us from
		# moving the unit.
		curve = Curve2D.new()


func initialize(unit_data: Dictionary):
	# Parameters
	# ----------
	# unit_data: Dictionary
	# {
	#	pilot: String. Path3D to the resource of the pilot
	#	mech: String. Path3D to the resource of the mech
	#	position: Vector2. Postion in the map in cells
	#	team: String. Team the unit is part of
	# }
	
	_pilot = load(unit_data['pilot'])
	_mech = load(unit_data['mech'])
	set_cell(unit_data['cell'])
	team = unit_data['team']
	
	pilot_name = _pilot.pilot_name
	mech_name = _mech.frame_name
	_stats.initialize(_pilot, _mech)
	_bar_hud.initialize(_stats.max_hp, _stats.heat_cap)
	move_range = _stats.speed
	
	actions_left = 2
	
	# Reset status and conditions
	for i in CONSTANTS.STATUS.values():
		status[i] = false
	
	for i in CONSTANTS.CONDITIONS.values():
		conditions[i] = 0
	conditions[CONSTANTS.CONDITIONS.LOCKED_ON] = 2
	
	#In the future this should also set the skin
	
	# The following lines initialize the `cell` property and snap the unit to the cell's center on the map.
	position = GlobalGrid.map_to_local(cell)


func _process(delta):
	_path_follow.progress += move_speed * delta
	
	if _path_follow.progress_ratio >= 1.0:
		_set_is_walking(false) # This also sets _process as false due to the setter bellow
		
		position = GlobalGrid.map_to_local(self.cell)
		_path_follow.progress = 0.01
		curve.clear_points()
		# Finally, we emit a signal. We'll use this one with the game board.
		emit_signal("walk_finished")


func walk_along(path: PackedVector2Array) -> void:
	# path is a set of points given as relative from the current position
	if path.is_empty():
		return
	
	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(GlobalGrid.map_to_local(point) - position)
	
	# Inmediately set the position to the last point
	_set_is_walking(true)
	used_move_range = min(used_move_range + path.size() - 1, move_range)

	set_cell(path[-1])
	

func finish_turn() -> void:
	used_move_range = 0
	actions_left = 2
	is_disengaging = false


func take_damage(damage: int, damage_type: int) -> void:
	show_hud()
	
	if damage == 0:
		LogRepeater.create_prompt("MISS", get_relative_pos())
		return
		
	LogRepeater.create_damage_prompt(damage, damage_type, get_relative_pos())
	
	if damage_type == CONSTANTS.DAMAGE_TYPES.HEAT:
		take_heat(damage)
		return
	_stats.hp -= damage
	_bar_hud.hp = _stats.hp


func take_heat(heat: int) -> void:
	_stats.heat -= heat
	_bar_hud.heat = _stats.heat


func take_structure(struct: int) -> void:
	_stats.structure -= struct
	_bar_hud.structure = _stats.structure


func take_stress(stress: int) -> void:
	_stats.stress -= stress
	_bar_hud.stress = _stats.stress


func overcharge():
	if actions_left >= 3:
		return
		
	self.actions_left += 1 # self. to trigger the setter
	overcharge_charges += 1
	
	match overcharge_charges:
		1:
			take_heat(1)
		2:
			take_heat(randi()%3+1)
		3:
			take_heat(randi()%6+1)
		_:
			take_heat(randi()%6+1 + 4)

func get_relative_pos() -> Vector2:
	return get_global_transform_with_canvas().get_origin()

# Maybe unnecesary, too verbose
func set_status(status_key: int, value: bool) -> void:
	if value == status[status_key]:
		return
		
	if not CONSTANTS.STATUS.values().has(status_key):
		print("Status not recognized")
		return
	
	status[status_key] = value 
	var p_or_m = "+ " if value else "- "
	var status_name: String = CONSTANTS.STATUS.keys()[status_key]
	LogRepeater.create_prompt(p_or_m+status_name, get_relative_pos())

func set_engaged_units(value: Array[Unit]):
	for e_unit in value:
		if e_unit.is_disengaging:
			value.erase(e_unit)
	
	if value.is_empty() or is_disengaging:
		engaged_units.clear()
		set_status(CONSTANTS.STATUS.ENGAGED, false)
		return
	
	engaged_units = value
	set_status(CONSTANTS.STATUS.ENGAGED, true)

# If disengaging is true and there are engaged units then each of the engaged units sees removed 
# the reference of this unit from their engaged units
func set_is_disengaging(value: bool):
	is_disengaging = value
	if is_disengaging and not engaged_units.is_empty():
		
		for e_unit in engaged_units: # Very horrible but it works
			var e_e_units = e_unit.engaged_units
			e_e_units.erase(self)
			e_unit.engaged_units = e_e_units
		
		engaged_units.clear()
		set_status(CONSTANTS.STATUS.ENGAGED, false)


func set_condition_time(condition_key: int, value: int) -> void:
	if not CONSTANTS.CONDITIONS.values().has(condition_key):
		print("Status not recognized")
		return
	
	conditions[condition_key] = value
	var condition_name: String = CONSTANTS.CONDITIONS.keys()[condition_key]
	LogRepeater.create_prompt(condition_name, get_relative_pos())


func set_actions_left(value: int) -> void:
	actions_left = value
	_bar_hud.actions = value

func set_skin(value: Texture2D) -> void:
	skin = value
	
	# Due to the onready preloading the sprite node might not be ready, wait using yield until the 
	# ready signal is recieved
	if not _sprite:
		await self.ready
	_sprite.texture = value

func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	# See above
	if not _sprite:
		await self.ready
	_sprite.position = value

func set_cell(val: Vector2) -> void:
	cell = GlobalGrid.clamp_position(val) # We don't want to have out-of-grid cells

func set_is_selected(val: bool) -> void:
	if is_selected == val:
		return
		
	is_selected = val
	if is_selected:
		_anim_player.play("selected")
		show_hud()
	else:
		_anim_player.play("idle") # idle animations reset the 'selected' animation
		hide_hud()

func _set_is_walking(val: bool) -> void:
	_is_walking = val
	set_process(_is_walking)

func _get_remaining_move_range() -> int:
	return move_range - used_move_range

# Get a dictionary of the weapons that have a threat and the affected cells
func get_threat() -> Array[WeaponAction]:
	var out : Array[WeaponAction] = []
	
	for weapon in _mech.weapons:
		for range_res in weapon.ranges:
			if range_res.type == CONSTANTS.WEAPON_RANGE_TYPES.THREAT:
				out.push_back(weapon)
	
	return out

func show_hud() -> void:
	_bar_hud.show()
	_status_hud.set_from_dict(status, conditions)
	
func hide_hud() -> void:
	_bar_hud.hide()
	_status_hud.clear()

