extends VBoxContainer
class_name ActionContainer

signal action_selected(weapon)

const BaseUIButton: PackedScene = preload("res://Scenes/UI/BaseUIButton.tscn")

func initialize(weapons: Array) -> void:
	for weapon in weapons:
		var weapon_button = BaseUIButton.instance()
		add_child(weapon_button)
		weapon_button.initialize(weapon.weapon_name)
		weapon_button.connect("pressed", self, "_on_BasicUIButton_pressed", [weapon])


func _on_BasicUIButton_pressed(weapon: Resource) -> void:
	emit_signal("action_selected", weapon)
