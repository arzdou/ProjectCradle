extends Resource
class_name BaseAction

# Structure based on the one used for json data for COMP/CON

# Basic information of the action
export var id: String
export var name: String
export(CONSTANTS.ACTION_TYPES) var action_type
export var terse: String
export var detail: String

# NO IDEA, NEED TO CHECK
export(Array, CONSTANTS.ACTIVATION_TYPE) var activation_type

# When is the action executable
export var pilot: bool
export var mech: bool = true

# Pointers to synnergies, I dont know if this will be useful
export var synergy: Array

# For the log chat
export(Array, String) var confirm
export var log_str: String

# Misc.
export var ignore_used: bool
export var heat_cost: bool

