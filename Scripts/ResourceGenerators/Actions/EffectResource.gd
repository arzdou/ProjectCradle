extends Resource
class_name EffectResource


export(CONSTANTS.EFFECT_ACTIVATION) var activation = CONSTANTS.EFFECT_ACTIVATION.EFFECT

export(Array, CONSTANTS.STATUS) var self_status
export(Array, CONSTANTS.STATUS) var target_status

export(Array, CONSTANTS.CONDITIONS) var self_conditions
export(Array, CONSTANTS.CONDITIONS) var target_conditions

func apply_effect(self_unit: Unit, target_unit: Unit) -> void:
	for ss in self_status:
		self_unit.set_status(ss, true)

	for ts in target_status:
		target_unit.set_status(ts, true)
		
	for sc in self_conditions:
		self_unit.set_condition_time(sc, 1)

	for tc in target_conditions:
		target_unit.set_condition_time(tc, 1)
	
