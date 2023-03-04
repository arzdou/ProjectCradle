extends VBoxContainer
class_name ActionContainer

const BaseUIButton: PackedScene = preload("res://Scenes/Unit/UnitHUD/BaseUIButton.tscn")

const HIDE_SPEED := 0.3  # second
const HIDE_DISPACEMENT = Vector2(50, 0) # pixels

var is_hidden := true
var button_array := []

func _ready():
	show_menu() # This fixes a graphical bug on the first call to show the menu, don't me ask why...
	hide_menu()


func create_menu_button(button_name: String):
	var menu_button := BaseUIButton.instantiate()
	add_child(menu_button)
	
	menu_button.initialize([button_name])

	menu_button.pressed.connect(
		owner.menu_button_pressed.bind(menu_button, self)
	)
	
	button_array.push_back(menu_button)
	
	return menu_button


func create_all_action_button(action):
	if action.action_type == CONSTANTS.ACTION_TYPES.WEAPON:
		for mode in range(action.ranges.size()):
			create_action_button(action, mode)
	else:
		create_action_button(action)

func create_action_button(action, mode: int = 0):
	var action_button := BaseUIButton.instantiate()
	add_child(action_button)
	
	action_button.initialize(action.get_display_name(mode))
	action_button.pressed.connect(
		owner.on_action_selected.bind(action, mode)
	)
	
	button_array.push_back(action_button)


func hide_menu() -> void:
	if is_hidden:
		return
	var tween = create_tween().set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_property(
		self, "position", position + HIDE_DISPACEMENT, HIDE_SPEED
	).from(position)
	tween.tween_property(
		self, "modulate", Color(1, 1, 1, 0), HIDE_SPEED
	).from(Color(1, 1, 1, 1))

	is_hidden = true
	await tween.finished
	hide()

func show_menu() -> void:
	reset_position()
	if not is_hidden:
		return
	show()
	var tween = create_tween().set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_property(
		self, "position", position - HIDE_DISPACEMENT, HIDE_SPEED
	).from(position)
	tween.tween_property(
		self, "modulate", Color(1, 1, 1, 1), HIDE_SPEED
	).from(Color(1, 1, 1, 0))

	is_hidden = false

func reset_position() -> void:
	position = HIDE_DISPACEMENT
