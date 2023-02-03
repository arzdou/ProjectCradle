# Represents a unit in the game board
# The board manages the Unit's position inside the game grid.
# The unit itself is only a visual representation that moves smoothly in the game world.
# We use the tool mode so the `skin` and `skin_offset` below update in the editor.
tool 
class_name Unit
extends Path2D


# Preload the `Grid.tres` resource you created in the previous part.
export(Resource) var grid = preload("res://Resources/Grid.tres")
export(Resource) var _pilot_stats = preload("res://Resources/Pilots/BasePilot.tres")
export(Resource) var _mech = preload("res://Resources/Frames/Everest.tres")

# Type of the unit
export(String, 'ally', 'enemy') var ally_or_enemy = 'ally'

# Texture representing the unit.
export var skin: Texture setget set_skin
export var skin_offset := Vector2.ZERO setget set_skin_offset

# Distance to which the unit can walk in cells.
export var move_range: int
# The unit's move speed in pixels, when it's moving along a path.
export var move_speed := 600.0

var pilot_name = _pilot_stats.pilot_name
var mech_name = _mech.frame_name

# Cell where the unit is located
var cell := Vector2.ZERO setget set_cell
var is_selected := false setget set_is_selected

# Through its setter function, the `_is_walking` property toggles processing for this unit.
# See `_set_is_walking()` at the bottom of this code snippet.
var _is_walking := false setget _set_is_walking

# Preload all components
onready var _sprite: Sprite = $PathFollow2D/Sprite
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _path_follow: PathFollow2D = $PathFollow2D
onready var _unit_hud = $PathFollow2D/UnitHUD
onready var _stats = $UnitStats

signal walk_finished


func _ready():
	# _process will only run if the unit needs to move
	set_process(false)
	_stats.initialize(_pilot_stats, _mech)
	_unit_hud.initialize(_stats.max_hp, _stats.heat_cap)
	move_range = _stats.speed
	# The following lines initialize the `cell` property and snap the unit to the cell's center on the map.
	self.cell = grid.world_to_map(position)
	position = grid.map_to_world(self.cell)
	
	if not Engine.editor_hint:
		# We create the curve resource here because creating it in the editor prevents us from
		# moving the unit.
		curve = Curve2D.new()



func _process(delta):
	_path_follow.offset += move_speed * delta
	
	if _path_follow.unit_offset >= 1.0:
		self._is_walking = false # This also sets _process as false due to the setter bellow
		
		position = grid.map_to_world(self.cell)
		_path_follow.offset = 0.0
		curve.clear_points()
		# Finally, we emit a signal. We'll use this one with the game board.
		emit_signal("walk_finished")


func walk_along(path: PoolVector2Array) -> void:
	# path is a set of points given as relative from the current position
	if path.empty():
		return
	
	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.map_to_world(point) - position)
	
	# Inmediately set the position to the last point
	self.cell = path[-1]
	self._is_walking = true


func set_skin(value: Texture) -> void:
	skin = value
	
	# Due to the onready preloading the sprite node might not be ready, wait using yield until the 
	# ready signal is recieved
	if not _sprite:
		yield(self, "ready")
	_sprite.texture = value


func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	# See above
	if not _sprite:
		yield(self, "ready")
	_sprite.position = value


func set_cell(val: Vector2) -> void:
	cell = grid.clamp_position(val) # We don't want to have out-of-grid cells


func set_is_selected(val: bool) -> void:
	is_selected = val
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle") # idle animations reset the 'selected' animation

func _set_is_walking(val: bool) -> void:
	_is_walking = val
	set_process(_is_walking)

func show_hud() -> void:
	_unit_hud.show()
	
func hide_hud() -> void:
	_unit_hud.hide()
