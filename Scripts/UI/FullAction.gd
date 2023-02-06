extends ActionContainer

signal action_selected(weapon)

func initialize(weapons: Array) -> void:
	for weapon in weapons:
		var weapon_button = BaseUIButton.instance()
		.add_child(weapon_button)
		weapon_button.initialize(weapon.weapon_name)
		weapon_button.connect("pressed", self, "_on_BasicUIButton_pressed", [weapon])
	.hide_menu()


func _on_BasicUIButton_pressed(weapon: Resource) -> void:
	.emit_signal("action_selected", weapon)
