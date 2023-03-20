extends Resource
class_name BaseAction

# Structure based on the one used for json data for COMP/CON

# Basic information of the action
@export var id: String
@export var name: String
@export var action_type: CONSTANTS.ACTION_TYPES # (CONSTANTS.ACTION_TYPES)

@export var menu_icon: Texture
@export var terse: String
@export var detail: String

@export var cost: int = 1

# NO IDEA, NEED TO CHECK
@export var activation_type: CONSTANTS.ACTIVATION_TYPE

# When is the action executable
@export var pilot: bool
@export var mech: bool = true

@export var synergies: Array
@export var no_synergy: bool

# For the log chat
@export var confirm: Array[String]
@export var log_str: String

# Misc.
@export var ignore_used: bool
@export var heat_cost: bool

# Returns an array with the ordered elements of the name: strings and icons
func get_display_name() -> Array:
	return [name]


func get_cells_in_range(_active_unit: Unit, _target_cell: Vector2) -> Dictionary:
	var out := {
		CONSTANTS.UOVERLAY_CELLS.MARKED: [],
		CONSTANTS.UOVERLAY_CELLS.DAMAGE: [],
		CONSTANTS.UOVERLAY_CELLS.MOVEMENT: [],
		CONSTANTS.UOVERLAY_CELLS.ARROW: [],
		CONSTANTS.UOVERLAY_CELLS.ARROW_BACK: []
	}
	return out


# Try to perform the action on a series of cells. Returns true if the action was performed correctly 
# and false if it failed to do it (do not confuse with missing or mechanically failing)
func try_to_act(_active_unit: Unit, _target_cell: Vector2) -> bool:
	return false


func can_act(_active_unit: Unit, _target_cell: Vector2) -> bool:
	return false
