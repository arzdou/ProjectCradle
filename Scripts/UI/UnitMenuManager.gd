extends Control
class_name UnitMenuManager

var attack_menu_buttons : Array = [
	preload("res://Resources/Actions/ram/ram.tres"),
	preload("res://Resources/Actions/improvised_attack/improvised_attack.tres")
]

var tech_menu_buttons : Dictionary = {
	"Bolster": null,
	"Scan": null,
	"Lock On": null,
	"Invade": null,
	# TECH
}

var back_button : Dictionary = {
	"menu_name": "MainMenu",
	"icon": null,
	"theme": null
}

var main_menu_buttons : Dictionary = {
	"Move": preload("res://Resources/Actions/standard_move.tres"),
	"Stabilize": null,
	"Disengage": preload("res://Resources/Actions/disengage/disengage.tres"),
	"Overcharge": preload("res://Resources/Actions/overcharge/overcharge.tres"),
		
	# Separator
	
	"Attack": {
		"menu_name": "AttackMenu",
		"base_buttons": attack_menu_buttons,
		"icon": preload("res://Media/icons/menu/attack.svg"),
		"theme": null
	},
	"Tech": {
		"menu_name": "TechMenu",
		"base_buttons": tech_menu_buttons,
		"icon": preload("res://Media/icons/menu/tech.svg"),
		"theme": null
	},
	"System": {
		"menu_name": "SystemMenu",
		"base_buttons": {},
		"icon": preload("res://Media/icons/menu/system.svg"),
		"theme": null
	},
	"Reaction": {
		"menu_name": "ReactionMenu",
		"base_buttons": {},
		"icon": preload("res://Media/icons/menu/reaction.svg"),
		"theme": null
	},
	"Protocol": {
		"menu_name": "ProtocolMenu",
		"base_buttons": {},
		"icon": preload("res://Media/icons/menu/protocol.svg"),
		"theme": null
	},
	
	# Separator
	
	"Boost": preload("res://Resources/Actions/boost.tres"),
	"Hide": null,
	"Search": null,
	"Shutdown/Start": null,
	"Mount/Dismount": null,
	"Self-Destruct": null,
	"End Turn": preload("res://Resources/Actions/end_turn/end_turn.tres")
}


signal action_button_pressed(action)
signal unit_activated

const ActionMenuButton: PackedScene = preload("res://Scenes/UI/ActionMenuButton.tscn")
const ExtendedMenuButton: PackedScene = preload("res://Scenes/UI/ExtendedMenuButton.tscn")

@onready var activate_menu = $MarginContainer/ActivateMenu
@onready var main_menu = $MarginContainer/MainMenu
@onready var attack_menu = $MarginContainer/AttackMenu
@onready var tech_menu = $MarginContainer/TechMenu
@onready var system_menu = $MarginContainer/SystemMenu
@onready var reaction_menu = $MarginContainer/ReactionMenu
@onready var protocol_menu = $MarginContainer/ProtocolMenu
@onready var activate_button = $MarginContainer/ActivateMenu/ActivateButton

@onready var active_menu = activate_menu : set = set_active_menu

var is_hidden: bool : set = set_is_hidden
# This array will contain all the button elements related to the unit which 
# will be deleted when the menu is cleared
var extra_elements: Array[Button]


func _ready():
	is_hidden = true
	
	activate_button.initialize("Activate", null)
	activate_button.pressed.connect(activate_unit)
	
	var mode = 0
	for button_name in main_menu_buttons:
		if mode == 0:
			create_action_button(main_menu_buttons[button_name], main_menu)
			if button_name == "Overcharge":
				mode = 1
				create_separator(main_menu)
		else:
			create_menu_button(button_name, main_menu_buttons[button_name], main_menu, button_name+"Button")
			mode = 0 if button_name == "Protocol" else 1
			if button_name == "Protocol":
				mode = 0
				create_separator(main_menu)

	
	create_menu_button("Return", back_button, attack_menu, "AttackButton")
	create_separator(attack_menu)
	for weapon in attack_menu_buttons:
		var button = ExtendedMenuButton.instantiate()
		button.theme_type_variation = "AttackButton"
		attack_menu.add_child(button)
		button.initialize(weapon)
		button.pressed.connect(on_action_button_pressed.bind(weapon))
		
	create_menu_button("Return", back_button, tech_menu, "TechButton")
	create_separator(tech_menu)
	for button_name in tech_menu_buttons:
		create_action_button(tech_menu_buttons[button_name], tech_menu, "TechButton")
	
	create_menu_button("Return", back_button, system_menu, "SystemButton")
	create_separator(system_menu)
	
	create_menu_button("Return", back_button, reaction_menu, "ReactionButton")
	create_separator(reaction_menu)
	
	create_menu_button("Return", back_button, protocol_menu, "ProtocolButton")
	create_separator(protocol_menu)

# The hide mechanic on the menu acts as a sort of clean
func set_is_hidden(value: bool):
	var tween = create_tween().set_trans(Tween.TRANS_CIRC).set_parallel(true)
	is_hidden = value
	
	# If not hidden just show the menu, which has been already set to activate menu and has 
	# been built on the function called by the signal
	if not is_hidden:
		show()
		tween.tween_property(self, "modulate", Color(1,1,1,1), 0.3).from(Color(1,1,1,0))
		return
		
	# If not hide the menu and reset the actions and active menu
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.3).from(Color(1,1,1,1))
	await tween.finished
	hide()
	set_active_menu(activate_menu)
	
	# Delete all actions specific to the unit
	for button in extra_elements:
		button.queue_free()
	extra_elements.clear()


func activate_unit():
	set_active_menu(main_menu)
	emit_signal("unit_activated")


func create_action_button(action: BaseAction, menu: HBoxContainer, variation: String = "") -> ActionMenuButton:
	var button = ActionMenuButton.instantiate()
	button.theme_type_variation = variation
	menu.add_child(button)
	if action:
		button.initialize(action.name, action.menu_icon)
		button.pressed.connect(on_action_button_pressed.bind(action))
	else:
		button.disabled = true
	return button

func create_extended_action_button(action: BaseAction, menu: HBoxContainer, variation: String = "") -> ExtendedMenuButton:
	var button = ExtendedMenuButton.instantiate()
	button.theme_type_variation = variation
	menu.add_child(button)
	if action:
		button.initialize(action)
		button.pressed.connect(on_action_button_pressed.bind(action))
	else:
		button.disabled = true
	return button

func on_action_button_pressed(action: BaseAction):
	emit_signal("action_button_pressed", action)



func create_menu_button(button_name: String, button_dict: Dictionary, menu: HBoxContainer, variation: String = ""):
	var menu_name = button_dict["menu_name"]
	var icon = button_dict["icon"]

	var button = ActionMenuButton.instantiate()
	button.theme_type_variation = variation
	menu.add_child(button)
	button.initialize(button_name, icon)
	button.pressed.connect(on_menu_button_pressed.bind(get_node("MarginContainer/"+menu_name))) # Its a bit choppy but it works

func on_menu_button_pressed(new_menu: HBoxContainer):
	set_active_menu(new_menu)



func create_separator(menu: HBoxContainer):
	var separator = TextureRect.new()
	menu.add_child(separator)
	separator.size = Vector2(25, 50)
	separator.texture = load("res://Media/HUD/menu_separator.png")


func set_active_menu(new_menu):
	if new_menu == active_menu:
		return
	
	var tween = create_tween().set_trans(Tween.TRANS_CIRC).set_parallel(true)
	
	tween.tween_property(new_menu, "modulate", Color(1,1,1,1), 0.3).from(Color(1,1,1,0))
	new_menu.show()
	
	tween.tween_property(active_menu, "modulate", Color(1,1,1,0), 0.3).from(Color(1,1,1,1))
	await tween.finished
	active_menu.hide()
	
	active_menu = new_menu


func _on_game_board_unit_selected(active_unit: Unit):

	# If the menu is not hidden it means that a different unit has been selected
	# First hide said unit and wait the tween timer
	if not is_hidden:
		set_is_hidden(true)
		await get_tree().create_timer(0.3).timeout
	
	# Create the menu for the new unit
	for weapon in active_unit._stats.mech_weapons:
		var button = create_extended_action_button(weapon, attack_menu, "AttackButton")
		extra_elements.push_back(button)
		
	for reaction in active_unit._stats.reactions:
		var button = create_action_button(reaction, reaction_menu, "ReactionButton")
		extra_elements.push_back(button)
		button.set_toggle()
		button.button_pressed = not active_unit._stats.is_reaction_active[reaction]
	
	# Play the start animation
	set_is_hidden(false)


func _on_game_board_unit_cleared():
	set_is_hidden(true)
