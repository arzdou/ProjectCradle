#This class will act as a relay between the CombatLog and all the nodes in the gameboard

extends Node

signal update_log(text)
signal clear_log()

# When we want to write the log we send a signal that will be captured by the CombatLog
func write(text: String):
	emit_signal("update_log", text)

func clear():
	emit_signal("clear_log")
