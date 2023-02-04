# Resource script to manage mechs' stats, mounts, traits and core_systems

extends Resource
class_name Mech

export var CONSTANTS: Resource = preload("res://Resources/CONSTANTS.tres")

export(String) var frame_name := 'MECH'
export(String, '1/2', '1', '2', '3') var size := '1'
export(int) var armor := 0
export(int) var save_target := 10
export(int) var sensors := 10

# HULL
export(int) var max_hp := 10
export(int) var repair_cap := 5

# AGILITY
export(int) var evasion := 8
export(int) var speed := 5

# SYSTEMS
export(int) var e_defense := 8
export(int) var tech_attack := 5
export(int) var system_points := 6

# ENGINEERING
export(int) var heat_cap := 6

export(Array, CONSTANTS.MOUNT_SIZES) var mounts
export(Array, Resource) var weapons
export(Array, Resource) var mech_systems
export(Resource) var core_system = null
