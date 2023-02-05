extends Resource
class_name Weapon

var CONSTANTS: Resource = preload("res://Resources/CONSTANTS.tres")
var action_type = CONSTANTS.ACTION_TYPES.WEAPON

export(String) var weapon_name = 'Weapon' 
export(CONSTANTS.MOUNT_SIZES) var size = CONSTANTS.MOUNT_SIZES.MAIN
export(CONSTANTS.WEAPON_TYPES) var type = CONSTANTS.WEAPON_TYPES.RIFLE


# Since Godot does not allow type hints for dictionaries and I am not sure how to do it otherwise, I will have to check validity everytime I load the resource...
# Weapon range should be given as {CONSTANTS.WEAPON_RANGE_TYPES: int, }
export(Dictionary) var weapon_range 
# Weapon damage should be given as {CONSTANTS.DAMAGE_TYPES: String or int, }
# String must be 'ndM' where n is the number of M dices to roll. int is fixed damage
export(Array, Dictionary) var weapon_damage = [{CONSTANTS.DAMAGE_TYPES.KINETIC: '1d6'}, {CONSTANTS.DAMAGE_TYPES.KINETIC: 3}, ]

export(Array, Resource) var tags

func _check_weapon_range() -> bool:
	print('hi')
	for key in weapon_range:
		var value = weapon_range[key]
		# If the key is not a weapon range or the value is not correct dont save
		if not CONSTANTS.WEAPON_RANGE_TYPES.has(key) or typeof(value) == TYPE_INT:
			return false
	return true


func _check_weapon_damage() -> bool:
	print('hi')
	for key in weapon_damage:
		var value = weapon_damage[key]
		# If the key is not a weapon damage or the value is not correct dont save
		if not CONSTANTS.DAMAGE_TYPES.has(key) or typeof(value) == TYPE_STRING:
			return false
	return true
