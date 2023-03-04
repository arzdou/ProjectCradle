extends Resource
class_name BaseAction

# Structure based on the one used for json data for COMP/CON

# Basic information of the action
@export var id: String
@export var name: String
@export var action_type: CONSTANTS.ACTION_TYPES # (CONSTANTS.ACTION_TYPES)
@export var terse: String
@export var detail: String

@export var cost: int = 1

# NO IDEA, NEED TO CHECK
@export var activation_type: Array[CONSTANTS.ACTIVATION_TYPE]

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
func get_display_name(mode: int = 0) -> Array:
	return [name]
