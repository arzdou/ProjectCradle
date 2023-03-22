extends BaseAction
class_name MiscAction

@export var effect: EffectResource

# Try to perform the action on a series of cells. Returns true if the action was performed correctly 
# and false if it failed to do it (do not confuse with missing or mechanically failing)
func try_to_act(active_unit: Unit, _target_cell: Vector2) -> bool:
	effect.apply_effect(active_unit, null)
	return true


func can_act(_active_unit: Unit, _target_cell: Vector2) -> bool:
	return true


func process(active_unit: Unit, _target_cell: Vector2) -> ResolvedAction:
	var out : ResolvedAction = resolved_action.new(self, active_unit, _target_cell)
	out.add_effect(effect, active_unit, null)
	return out

