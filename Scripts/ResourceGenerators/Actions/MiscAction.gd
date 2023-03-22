extends BaseAction
class_name MiscAction

@export var effect: EffectResource


func process(active_unit: Unit, _target_cell: Vector2) -> ResolvedAction:
	var out : ResolvedAction = resolved_action.new(self, active_unit, _target_cell)
	out.add_effect(effect, active_unit, null)
	return out

