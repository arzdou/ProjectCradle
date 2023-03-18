extends BaseAction
class_name MiscAction

@export var effect: EffectResource


# Try to perform the action on a series of cells. Returns true if the action was performed correctly 
# and false if it failed to do it (do not confuse with missing or mechanically failing)
func try_to_act(active_unit: Unit, _target_cell: Vector2) -> bool:
	effect.apply_effect(active_unit, null)
	emit_signal("action_finished")
	return true
