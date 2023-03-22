extends BaseAction
class_name ReactionAction

@export var active: bool = true
@export var turn_limit: int = 1
@export var prompt_text: String = "Reaction activated! Choose action:"
@export var trigger: TriggerResource


func get_possible_reactions(resolved_action: ResolvedAction, reacting_unit: Unit, acting_unit: Unit) -> Array[BaseAction]:
	return trigger.get_triggered_actions(resolved_action, reacting_unit, acting_unit) 
