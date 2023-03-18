extends BaseAction
class_name WeaponAction

@export var source: String = "GMS"
@export var licence: String = "GMS"
@export var license_id: String = ""
@export var license_level: int = 0

@export var mount = CONSTANTS.WEAPON_SIZE.MAIN # (CONSTANTS.WEAPON_SIZE)
@export var weapon_type = CONSTANTS.WEAPON_TYPES.RIFLE # (CONSTANTS.WEAPON_TYPES)

@export var barrage: bool
@export var skirmish: bool
@export var no_attack: bool
@export var no_mods: bool
@export var no_core_bonus: bool

@export var damage: Array[DamageResource] # Damage resource # (Array, Resource)
@export var ranges: Array[RangeResource]  # Range resource # (Array, Resource)
@export var tag: Array[Resource]          # Tag resource # (Array, Resource)

@export var sp: int = 0
@export var description: String

@export var actions: Array  # Action resource
@export var bonuses: Array  # Bonus resource
@export var no_bonus: bool

# Resource that contains the effects of the action, use the bool to mark that the effect is active
@export var is_effect: bool
@export var effects: EffectResource
@export var is_on_attack: bool
@export var on_attack: EffectResource
@export var is_on_hit: bool
@export var on_hit: EffectResource
@export var is_on_crit: bool
@export var on_crit: EffectResource

@export var deployable: Array  # Deployable resource
@export var counters: Array    # Counter resource

@export var integrated: Array
@export var special_equipment: Array

# Maybe using this variable is not the best since resources are shared but I don't really 
# want to be carrying arround the mode variable...
var range_mode: int = 0 : set = set_range_mode
func set_range_mode(value: int):
	range_mode = clamp(value, 0, ranges.size())

const range_type_dict = {
	CONSTANTS.WEAPON_RANGE_TYPES.RANGE: "res://Media/icons/range/range.svg",
	CONSTANTS.WEAPON_RANGE_TYPES.LINE: "res://Media/icons/range/aoe_line.svg",
	CONSTANTS.WEAPON_RANGE_TYPES.CONE: "res://Media/icons/range/aoe_cone.svg",
	CONSTANTS.WEAPON_RANGE_TYPES.BLAST: "res://Media/icons/range/aoe_blast.svg",
	CONSTANTS.WEAPON_RANGE_TYPES.BURST: "res://Media/icons/range/aoe_burst.svg",
	CONSTANTS.WEAPON_RANGE_TYPES.THREAT: "res://Media/icons/range/threat.svg",
}


func get_display_name() -> Array:
	var text = "%s - %d" % [name, ranges[range_mode].range_value]
	var icon = load(range_type_dict[ranges[range_mode].type])
	return [text, icon]


# Just a wrapper around the resource function taking into account the different range modes
func get_cells_in_range(active_unit: Unit, target_cell: Vector2) -> Dictionary:
	return ranges[range_mode].get_cells_in_range(active_unit.cell, target_cell)


# Perform the weapon attack over an area. If the area contains an enemy it will return true 
# and the action will be considered complete
func try_to_act(active_unit: Unit, target_cell: Vector2) -> bool:
	var damage_cells = get_cells_in_range(active_unit, target_cell)[CONSTANTS.UOVERLAY_CELLS.DAMAGE]
	var has_acted = try_to_apply_damage_in_area(active_unit, damage_cells)
	
	
	if not has_acted:
		return false
	return true


# Calculates the cells in range and checks if the target cell is cointained in "in_range"
func is_in_range(origin_cell: Vector2, target_cell: Vector2) -> bool:
	var cells_in_range = ranges[range_mode].get_cells_in_range(origin_cell, target_cell)
	return cells_in_range[CONSTANTS.UOVERLAY_CELLS.MARKED].has(target_cell)


# Returns true if the WeaponAction managed to hit (or miss) an attack
func try_to_apply_damage_in_area(active_unit: Unit, area: Array) -> bool:
	var damage_applied := false
	for target_cell in area:
		# If *any* damage was done consider this action complete
		damage_applied = damage_applied or try_to_apply_damage(active_unit, target_cell)
		
	return damage_applied


# This function tries to apply an array of damage on top of a cell, if the cell is empty it will 
# return false and if the damage was applied it will return true
func try_to_apply_damage(active_unit: Unit, target_cell: Vector2) -> bool:
	
	# There are two conditions to apply damage:
	# 1. The cell has a unit
	# 2. You cannot be the target
	
	var target_unit: Unit = GlobalGrid.in_cell(target_cell)
	
	if not target_unit:
		return false
		
	if target_unit == active_unit:
		return false
	
	if is_on_attack:
		on_attack.apply_effect(active_unit, target_unit)
	
	# Roll to see if the attack connects
	if not attack_roll(active_unit, target_unit):
		target_unit.take_damage(0, 0)
		return true
	
	if is_on_hit:
		on_hit.apply_effect(active_unit, target_unit)
	
	# Apply all damages
	for damage_resource in damage:
		var damage_dealt = damage_resource.roll_damage()
		target_unit.take_damage(damage_dealt, damage_resource.type)
	
	return true


# Perform an attack roll against a character
func attack_roll(active_unit: Unit, target_unit: Unit) -> bool:
		
	# Attacks to invisible characters miss half of the time
	if target_unit.status[CONSTANTS.STATUS.INVISIBLE]:
		var coin_toss = randi()%2
		if coin_toss:
			return true
	
	# Accuracy aids on the roll by giving extra d20's and then taking the best (or worst)
	# Accuracy is given by the enemy being prone and exposed
	# Accuracy is taken when the unit is impared or attacking with a ranged weapon when engaged
	# Hard cover gives -2 accuracy and soft cover gives -1
	var accuracy: int = (
		int(target_unit.status[CONSTANTS.STATUS.PRONE]) +
		int(target_unit.status[CONSTANTS.STATUS.EXPOSED]) + 
		-1*int(active_unit.conditions[CONSTANTS.CONDITIONS.IMPAIRED]) +
		-1*int(active_unit.status[CONSTANTS.STATUS.ENGAGED] and ranges[range_mode].type != CONSTANTS.WEAPON_RANGE_TYPES.THREAT) +
		GlobalGrid.find_cover_from_attack(active_unit.cell, target_unit.cell)
	)
	
	var roll_array := []
	for _i in range(1 + accuracy):
		roll_array.push_back(randi() % 20 + 1)
	roll_array.sort()
	
	var shift: int = accuracy if accuracy>0 else 0 # Shift the array to get the highest or lowest values
	var roll = GlobalGrid.sum_int_array(roll_array.slice(shift, 1 + shift))
	
	return roll + active_unit._stats.grit >= target_unit._stats.evasion 


