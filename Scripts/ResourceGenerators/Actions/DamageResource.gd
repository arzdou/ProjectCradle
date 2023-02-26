extends Resource
class_name DamageResource

export(CONSTANTS.DAMAGE_TYPES) var type
export var number_of_dices: int = 1
export var dice_faces: int = 6
export var constant_damage: int = 0


func roll_damage(accuracy: int = 0) -> int:
	
	# Roll the damage described by the resource and apply accuracy or difficulty (accuracy < 0)
	
	var damage_array := []
	for _i in range(number_of_dices + accuracy):
		damage_array.push_back(randi() % dice_faces + 1)
	damage_array.sort()
	
	var shift: int = accuracy if accuracy>0 else 0 # Shift the array to get the highest or lowest values
	var roll = GlobalGrid.sum_int_array(damage_array.slice(shift, number_of_dices + shift))
	
	return roll + constant_damage
