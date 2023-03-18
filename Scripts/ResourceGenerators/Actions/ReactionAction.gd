extends BaseAction
class_name ReactionAction

@export var active: bool = true
@export var turn_limit: int = 1
@export var trigger: TriggerResource
@export var effect: EffectResource

func check_activation(action: BaseAction, reacting_unit: Unit, acting_unit: Unit) -> bool:
	return trigger.check_trigger(action, reacting_unit, acting_unit)


# Try to perform the action on a series of cells. Returns true if the action was performed correctly 
# and false if it failed to do it (do not confuse with missing or mechanically failing)
func try_to_act(active_unit: Unit, target_cell: Vector2) -> bool:
	var target_unit: Unit = GlobalGrid.in_cell(target_cell)
	if not target_unit:
		return false
	effect.apply_effect(active_unit, target_unit)
	
	emit_signal("action_finished")
	return true
