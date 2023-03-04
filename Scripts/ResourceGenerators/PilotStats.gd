extends Resource
class_name PilotStats

@export var pilot_name: String = 'BRIGADOR'
@export var license_level = 0 # (int, 0, 12)

# Basic stats for a pilot
var size := '1/2'
var max_hp:  int =  6 : get = _get_max_hp
var evasion:       int = 10 : get = _get_evasion
var e_defense:     int = 10 : get = _get_e_defense
var speed:         int =  4 : get = _get_speed

# Level up stats
@export var hull: int = 0
@export var agility: int = 0
@export var systems: int = 0
@export var engineering: int = 0

# Equipment of the pilot
# TO DO: Define the different types of resources
@export var armor: Resource = null
@export var weapon: Resource = null
@export var gear = [] # (Array, Resource)
@export var traits = [] # (Array, Resource)


func _get_max_hp() -> int:
	return max_hp # TO DO: add items

func _get_evasion() -> int:
	return evasion # TO DO: + armor.evasion

func _get_e_defense() -> int:
	return e_defense # TO DO  + armor.e_defense

func _get_speed() -> int:
	return speed # TO DO  + armor.e_defense + gear



