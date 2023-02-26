extends VBoxContainer
class_name ActionContainer

const BaseUIButton: PackedScene = preload("res://Scenes/Unit/UnitHUD/BaseUIButton.tscn")

const HIDE_SPEED := 0.15  # second
const HIDE_DISPACEMENT = Vector2(50, 0) # pixels

var hidden := true
var button_array := []

onready var tween = $Tween

func _ready():
	show_menu() # This fixes a graphical bug on the first call to show the menu, don't me ask why...
	hide_menu()
	#tween.connect("tween_all_completed", self, '_on_Tween_tween_all_completed')



func create_menu_button(button_name: String):
	var menu_button := BaseUIButton.instance()
	add_child(menu_button)
	
	menu_button.initialize(button_name)
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
			var extra_name = " - %d %s"%[action.ranges[mode].range_value, CONSTANTS.WEAPON_RANGE_TYPES.keys()[action.ranges[mode].type]]
			create_action_button(action, mode, extra_name)
	else:
		create_action_button(action)

func create_action_button(action, mode: int = 0, extra_name: String = ''):
	var action_button := BaseUIButton.instance()
	add_child(action_button)
	
	action_button.initialize(action.name + extra_name)
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
	
	tween.interpolate_property(
		self, "rect_position", rect_position, rect_position + HIDE_DISPACEMENT, HIDE_SPEED
	)
	tween.interpolate_property(
		self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), HIDE_SPEED
	)
	tween.start()
	hidden = true
	yield(tween, 'tween_all_completed')
	hide()

func show_menu() -> void:
	reset_position()
	if not hidden:
		return
	
	show()
	tween.interpolate_property(
		self, "rect_position", rect_position, rect_position - HIDE_DISPACEMENT, HIDE_SPEED
	)
	tween.interpolate_property(
		self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), HIDE_SPEED
	)
	
	tween.start()
	hidden = false

func reset_position() -> void:
	rect_position = HIDE_DISPACEMENT
