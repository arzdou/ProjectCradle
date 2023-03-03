extends VBoxContainer
class_name ActionContainer

const BaseUIButton: PackedScene = preload("res://Scenes/Unit/UnitHUD/BaseUIButton.tscn")

const HIDE_SPEED := 0.3  # second
const HIDE_DISPACEMENT = Vector2(50, 0) # pixels

var hidden := true
var button_array := []

func _ready():
	show_menu() # This fixes a graphical bug on the first call to show the menu, don't me ask why...
	hide_menu()



func create_menu_button(button_name: String):
	var menu_button := BaseUIButton.instance()
	add_child(menu_button)
	
	menu_button.initialize([button_name])
	menu_button.connect(
		"pressed", self, "_on_menu_button_pressed", [menu_button]
	)
	
	button_array.push_back(menu_button)
	
	return menu_button

func _on_menu_button_pressed(button_pressed: BaseUIButton) -> void:
	hide_menu()
	owner.menu_button_pressed(button_pressed, self)



func create_all_action_button(action):
	if action.action_type == CONSTANTS.ACTION_TYPES.WEAPON:
		for mode in range(action.ranges.size()):
			create_action_button(action, mode)
	else:
		create_action_button(action)

func create_action_button(action, mode: int = 0):
	var action_button := BaseUIButton.instance()
	add_child(action_button)
	
	action_button.initialize(action.get_display_name(mode))
	action_button.connect(
		"pressed", self, "_on_action_button_pressed", [action, mode]
	)
	
	button_array.push_back(action_button)

func _on_action_button_pressed(action: Resource, mode: int) -> void:
	hide_menu()
	owner.on_action_selected(action, mode, self)



func hide_menu() -> void:
	if hidden:
		return
	var tween = create_tween().set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_property(
		self, "rect_position", rect_position + HIDE_DISPACEMENT, HIDE_SPEED
	).from(rect_position)
	tween.tween_property(
		self, "modulate", Color(1, 1, 1, 0), HIDE_SPEED
	).from(Color(1, 1, 1, 1))

	hidden = true
	yield(tween, 'finished')
	hide()

func show_menu() -> void:
	reset_position()
	if not hidden:
		return
	
	show()
	var tween = create_tween().set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_property(
		self, "rect_position", rect_position - HIDE_DISPACEMENT, HIDE_SPEED
	).from(rect_position)
	tween.tween_property(
		self, "modulate", Color(1, 1, 1, 1), HIDE_SPEED
	).from(Color(1, 1, 1, 0))

	hidden = false

func reset_position() -> void:
	rect_position = HIDE_DISPACEMENT
