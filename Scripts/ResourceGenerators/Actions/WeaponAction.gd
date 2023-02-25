extends Resource
class_name WeaponAction

var action_type = CONSTANTS.ACTION_TYPES.WEAPON

export var id: String = "missing_mechweapon"
export var name: String = "ERR: DATA NOT FOUND"
export var source: String = "GMS"
export var licence: String = "GMS"
export var license_id: String = ""
export var license_level: int = 0

export(CONSTANTS.WEAPON_SIZE) var mount = CONSTANTS.WEAPON_SIZE.MAIN
export(CONSTANTS.WEAPON_TYPES) var weapon_type = CONSTANTS.WEAPON_TYPES.RIFLE

export var cost: int = 1
export var barrage: bool
export var skirmish: bool
export var no_attack: bool
export var no_mods: bool
export var no_core_bonus: bool

export(Array, Resource) var damage  # Damage resource
export(Array, Resource) var ranges  # Range resource
export(Array, Resource) var tag     # Tag resource

export var sp: int = 0
export var description: String

export var actions: Array  # Action resource
export var bonuses: Array  # Bonus resource
export var no_bonus: bool

export var synergis: Array
export var no_synergy: bool

export var deployable: Array  # Deployable resource
export var counters: Array    # Counter resource

export var integrated: Array
export var special_equipment: Array


func effect():
	pass

func on_attack():
	pass

func on_hit():
	pass

func on_crit():
	pass
	