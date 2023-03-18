extends AspectRatioContainer
class_name PromptMenu

signal action_selected(action)

const ExtendedMenuButton: PackedScene = preload("res://Scenes/UI/ExtendedMenuButton.tscn")

@onready var button_container = $ColorRect/ButtonContainer
@onready var label = $ColorRect/Label

func initialize(text: String, actions: Array[BaseAction]):
	label.text = text
	for action in actions:
		var button = ExtendedMenuButton.instantiate()
		button_container.add_child(button)
		button.initialize(action)
		button.pressed.connect(
			on_extended_menu_button_pressed.bind(action)
		)
	
	
	await button_container.resized
	button_container.position.x = self.size.x/2 - button_container.size.x/2 
	button_container.show()


func on_extended_menu_button_pressed(action: BaseAction):
	emit_signal("action_selected", action)


func _on_return_button_pressed():
	emit_signal("action_selected", null)
