extends Control
class_name UnitMenuManager

var attack_menu_buttons : Dictionary = {
	"Ram": {
		"action": preload("res://Resources/Actions/ram/ram.tres"),
		"icon": null
		},
	"Grapple": {
		"action": null, 
		"icon": null
		},
	"Improvised Attack": {
		"action": null, 
		"icon": null
		}
	# WEAPONS
}

var tech_menu_buttons : Dictionary = {
	"Bolster": {
		"action": null, 
		"icon": null
		},
	"Scan": {
		"action": null, 
		"icon": null
		},
	"Lock On": {
		"action": null, 
		"icon": null
		},
	"Invade": {
		"action": null, 
		"icon": null
		},
	# TECH
}

var system_menu_buttons : Dictionary = {
	# SYSTEMS
}

var reaction_menu_buttons : Dictionary = {
	"Overwatch": {
		"action": null, 
		"icon": null
		},
	"Brace": {
		"action": null, 
		"icon": null
		}
	# REACTIONS
}

var protocol_menu_buttons : Dictionary = {
	# PROTOCOL
}

var back_button : Dictionary = {
	"menu_name": "MainMenu",
	"icon": null,
	"theme": null
}

var main_menu_buttons : Dictionary = {
	"Move": {
		"action": preload("res://Resources/Actions/standard_move.tres"), 
		"icon": preload("res://Media/icons/menu/move.svg")
		},
	"Stabilize": {
		"action": null, 
		"icon": preload("res://Media/icons/menu/stabilize.svg")
		},
	"Disengage": {
		"action": null, 
		"icon": preload("res://Media/icons/menu/disengage.svg")
		},
	"Overcharge": {
		"action": null, 
		"icon": preload("res://Media/icons/menu/overcharge.svg")
		},
		
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
		"base_buttons": system_menu_buttons,
		"icon": preload("res://Media/icons/menu/system.svg"),
		"theme": null
	},
	"Reaction": {
		"menu_name": "ReactionMenu",
		"base_buttons": reaction_menu_buttons,
		"icon": preload("res://Media/icons/menu/reaction.svg"),
		"theme": null
	},
	"Protocol": {
		"menu_name": "ProtocolMenu",
		"base_buttons": protocol_menu_buttons,
		"icon": preload("res://Media/icons/menu/protocol.svg"),
		"theme": null
	},
	
	# Separator
	
	"Boost": {
		"action": preload("res://Resources/Actions/boost.tres"), 
		"icon": preload("res://Media/icons/menu/boost.svg")
		},
	"Hide": {
		"action": null,
		"icon": preload("res://Media/icons/menu/hide.svg")
		},
	"Search": {
		"action": null, 
		"icon": preload("res://Media/icons/menu/search.svg")
		},
	"Shutdown/Start": {
		"action": null, 
		"icon": preload("res://Media/icons/menu/shutdown.svg")
		},
	"Mount/Dismount": {
		"action": null, 
		"icon": preload("res://Media/icons/menu/mount.svg")
		},
	"Self-Destruct": {
		"action": null, 
		"icon": preload("res://Media/icons/menu/self-destruct.svg")
		}
}


signal action_button_pressed(action)
signal unit_activated

const ActionMenuButton: PackedScene = preload("res://Scenes/UI/ActionMenuButton.tscn")

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
var extra_elements: Array[ActionMenuButton]


func _ready():
	is_hidden = true
	
	activate_button.initialize("Activate", null)
	activate_button.pressed.connect(activate_unit)
	
	var mode = 0
	for button_name in main_menu_buttons:
		if mode == 0:
			create_action_button(button_name, main_menu_buttons[button_name], main_menu)
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
	for button_name in attack_menu_buttons:
		create_action_button(button_name, attack_menu_buttons[button_name], attack_menu, "AttackButton")
	
	create_menu_button("Return", back_button, tech_menu, "TechButton")
	create_separator(tech_menu)
	for button_name in tech_menu_buttons:
		create_action_button(button_name, tech_menu_buttons[button_name], tech_menu, "TechButton")
	
	create_menu_button("Return", back_button, system_menu, "SystemButton")
	create_separator(system_menu)
	for button_name in system_menu_buttons:
		create_action_button(button_name, system_menu_buttons[button_name], system_menu, "SystemButton")
	
	create_menu_button("Return", back_button, reaction_menu, "ReactionButton")
	create_separator(reaction_menu)
	for button_name in reaction_menu_buttons:
		create_action_button(button_name, reaction_menu_buttons[button_name], reaction_menu, "ReactionButton")
	
	create_menu_button("Return", back_button, protocol_menu, "ProtocolButton")
	create_separator(protocol_menu)
	for button_name in protocol_menu_buttons:
		create_action_button(button_name, protocol_menu_buttons[button_name], protocol_menu, "ProtocolButton")


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


func activate_unit():
	set_active_menu(main_menu)
	emit_signal("unit_activated")


func create_action_button(button_name: String, button_dict: Dictionary, menu: HBoxContainer, variation: String = ""):
	var action = button_dict["action"]
	var icon = button_dict["icon"]

	var button = ActionMenuButton.instantiate()
	button.theme_type_variation = variation
	menu.add_child(button)
	button.initialize(button_name, icon)
	button.pressed.connect(on_action_button_pressed.bind(action))
	if not action:
		button.disabled = true

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
	for weapon in active_unit._mech.weapons:
		var wdict = {"icon": null, "action": weapon}
		create_action_button(weapon.name, wdict, attack_menu, "AttackButton")
	if not is_hidden:
		set_is_hidden(true)
		await get_tree().create_timer(0.3).timeout
	set_is_hidden(false)


func _on_game_board_unit_cleared():
	set_is_hidden(true)
