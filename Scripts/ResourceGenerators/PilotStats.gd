extends Resource
class_name PilotStats

export(String) var pilot_name = 'BRIGADOR'
export(int, 0, 12) var license_level = 0

# Basic stats for a pilot
var size := '1/2'
var max_hp:  int =  6 setget ,_get_max_hp
var evasion:       int = 10 setget ,_get_evasion
var e_defense:     int = 10 setget ,_get_e_defense
var speed:         int =  4 setget ,_get_speed

# Level up stats
export(int) var hull = 0
export(int) var agility = 0
export(int) var systems = 0
export(int) var engineering = 0

# Equipment of the pilot
# TO DO: Define the different types of resources
export(Resource) var armor = null
export(Resource) var weapon = null
export(Array, Resource) var gear = []
export(Array, Resource) var traits = []


func _get_max_hp() -> int:
	return max_hp # TO DO: add items

func _get_evasion() -> int:
	return evasion # TO DO: + armor.evasion

func _get_e_defense() -> int:
	return e_defense # TO DO  + armor.e_defense

func _get_speed() -> int:
	return speed # TO DO  + armor.e_defense + gear



