# Node to manage the stats of the pilot and the mech based on the resources given by the parent node
extends Node
class_name UnitStats

signal structure_reduced(new_structure)
signal stress_raised(new_stress)

var license_level: int
var grit: int setget ,_get_grit

# Basic stats for a pilot
var pilot_size: String
var pilot_max_hp: int 
var pilot_hp: int setget _set_pilot_hp
var pilot_evasion: int 
var pilot_e_defense: int 
var pilot_speed: int 

# Level up stats
var hull: int 
var agility: int
var systems: int
var engineering: int

# Equipment of the pilot
# TO DO: Define the different types of resources
var pilot_armor: Resource
var pilot_weapon: Resource
var pilot_gear: Array
var pilot_traits: Array

var size: String
var armor: int
var save_target : int
var sensors: int

# HULL
var max_hp: int setget ,_get_max_hp
var hp: int setget _set_hp
var repair_cap: int setget ,_get_repair_cap

# AGILITY
var evasion: int setget ,_get_evasion
var speed: int setget ,_get_speed

# SYSTEMS
var e_defense: int setget ,_get_e_defense
var tech_attack: int setget ,_get_tech_attack
var system_points: int setget ,_get_system_points

# ENGINEERING
var heat_cap: int setget ,_get_heat_cap
var heat: int setget _set_heat

var structure := 4
var stress := 0

var mech_weapons: Array
var mech_systems: Array
var core_system: Resource


func initialize(pilot_stats: PilotStats, mech: Mech) -> void:
	license_level = pilot_stats.license_level

	pilot_size = pilot_stats.size
	pilot_max_hp = pilot_stats.max_hp
	pilot_hp = pilot_max_hp
	pilot_evasion = pilot_stats.evasion
	pilot_e_defense = pilot_stats.e_defense
	pilot_speed = pilot_stats.speed

	hull = pilot_stats.hull
	agility = pilot_stats.agility
	systems = pilot_stats.systems
	engineering = pilot_stats.engineering

	pilot_armor = pilot_stats.armor
	pilot_weapon = pilot_stats.weapon
	pilot_gear = pilot_stats.gear
	pilot_traits = pilot_stats.traits
	
	size = mech.size
	armor = mech.armor
	save_target = mech.save_target
	sensors = mech.sensors

	max_hp = mech.max_hp
	hp = max_hp
	repair_cap = mech.repair_cap
	evasion = mech.evasion
	speed = mech.speed
	e_defense = mech.e_defense
	tech_attack = mech.tech_attack
	system_points = mech.system_points
	heat_cap = mech.heat_cap
	heat = heat_cap
	
	mech_weapons = mech.weapons
	mech_systems = mech.mech_systems
	core_system = mech.core_system
	
	if not _check_validity():
		print('Mech not valid for the operating pilot') # Hacer algo


# Checks if the pilot can use the mech
func _check_validity() -> bool:
	# Sum of all stats should not exceed LL + 2
	if hull + agility + systems + engineering > license_level + 2:
		return false
	
	# TODO: check that the number of system points in the mech doesnt exceed the cap 
	# and that the pilot has all the required liceses
	if not mech_systems.empty():
		var mounted_system_points = 0
		for system in mech_systems:
			mounted_system_points += 0 # system.points
			# if system.license not in licenses:
			#	 return false
		if mounted_system_points > system_points:
			return false
			
	return true

func _set_pilot_hp(new_hp: int) -> void:
	pilot_hp = max(0, new_hp)
	
func _set_hp(new_hp: int) -> void:
	hp = new_hp
	while hp <= 0:
		structure -= 1
		hp = max_hp - abs(hp)
		emit_signal("structure_reduced", structure)

func _set_heat(new_heat: int) -> void:
	heat = new_heat
	while heat <= 0:
		stress -= 1
		heat = heat_cap - abs(heat)
		emit_signal("stress_raised", stress)

func _get_grit() -> int:
	return int(ceil(float(license_level) / 2))

func _get_max_hp() -> int:
	return max_hp + 2*hull + grit

func _get_repair_cap() -> int:
	return repair_cap + int(ceil(float(hull) / 2))

func _get_evasion() -> int:
	return evasion + agility

func _get_speed() -> int:
	return speed + agility

func _get_e_defense() -> int:
	return e_defense + systems

func _get_tech_attack() -> int:
	return tech_attack + systems

func _get_system_points() -> int:
	return system_points + systems + grit

func _get_heat_cap() -> int:
	return heat_cap + engineering

