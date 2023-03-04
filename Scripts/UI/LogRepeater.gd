#This class will act as a relay between the CombatLog and all the nodes in the gameboard

extends Node

signal write_log(text)
signal clear_log()
signal create_prompt_label(text, position)
signal create_damage_prompt_label(value, type, position)

# When we want to write the log we send a signal that will be captured by the CombatLog
func write(text: String):
	emit_signal("write_log", text)

func clear():
	emit_signal("clear_log")

func create_prompt(text: String, position: Vector2):
	emit_signal("create_prompt_label", text, position)

func create_damage_prompt(value: int, type: int, position: Vector2):
	emit_signal("create_damage_prompt_label", value, type, position)
