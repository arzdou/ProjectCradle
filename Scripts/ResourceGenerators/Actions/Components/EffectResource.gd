extends Resource
class_name EffectResource


@export var activation = CONSTANTS.EFFECT_ACTIVATION.EFFECT # (CONSTANTS.EFFECT_ACTIVATION)

@export var self_status: Array[CONSTANTS.STATUS]
@export var target_status: Array[CONSTANTS.STATUS]

@export var self_conditions: Array[CONSTANTS.CONDITIONS]
@export var target_conditions: Array[CONSTANTS.CONDITIONS]

@export var overcharge: bool
@export var disengage: bool
@export var brace: bool

func apply_effect(self_unit: Unit, target_unit: Unit) -> void:
	for ss in self_status:
		self_unit.set_status(ss, true)

	for ts in target_status:
		target_unit.set_status(ts, true)
		
	for sc in self_conditions:
		self_unit.set_condition_time(sc, 1)

	for tc in target_conditions:
		target_unit.set_condition_time(tc, 1)
	
	if overcharge:
		self_unit.overcharge()
	
	if disengage:
		self_unit.is_disengaging = true
	
	if brace:
		self_unit.is_bracing = true
