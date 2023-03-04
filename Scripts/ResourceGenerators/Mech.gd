# Resource script to manage mechs' stats, mounts, traits and core_systems

extends Resource
class_name Mech

@export var frame_name: String = 'MECH'
@export var size := '1' # (String, '1/2', '1', '2', '3')
@export var armor: int = 0
@export var save_target: int = 10
@export var sensors: int = 10

# HULL
@export var max_hp: int = 10
@export var repair_cap: int = 5

# AGILITY
@export var evasion: int = 8
@export var speed: int = 5

# SYSTEMS
@export var e_defense: int = 8
@export var tech_attack: int = 5
@export var system_points: int = 6

# ENGINEERING
@export var heat_cap: int = 6

@export var mounts: Array[CONSTANTS.MOUNT_SIZES]
@export var weapons: Array[WeaponAction]
@export var mech_systems: Array[Resource]
@export var core_system: Resource = null
