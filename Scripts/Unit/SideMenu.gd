extends ViewportContainer
class_name SideMenu

signal action_selected(action)

const ActionContainer: PackedScene = preload("res://Scenes/UI/ActionContainer.tscn")
const BaseUIButton: PackedScene = preload("res://Scenes/UI/BaseUIButton.tscn")

export var menu_size := Vector2(250, 200)

onready var main_container = $MainContainer

# This variable will hold references to the relations between buttons and containers
# Its used for transitioning between menus
var button_to_container_ref := {}


func initialize(menu_dictionary: Dictionary) -> void:
	main_container.set_owner(self)
	create_menu_recursively(menu_dictionary, main_container)
	main_container.hide_menu()
	hide()
	
	
func create_menu_recursively(menu_dictionary: Dictionary, parent_container: ActionContainer) -> void:
	# Function to create the side menu recursively, its a bit of a mess but I really really really 
	# didn't want to hardcode the menu and create some parts of it, since the action tree can be 
	# quite mesy. This took me way to long to code correctly so I'm leaving a nice long comment.
	
	# Arguments
	# ________
	
	# menu_dictionary: Dictionary
	#	Dictionary that contains the structure of the menu, they keys will be the name of the button 
	#   and the values can be either dictionaries or arrays
	#   Example: 
	#		menu_dictionary: {
	#			"FULL ACTION": {
	#				"WEAPONS": [weapon1, weapon2]
	#				"FULL TECH": [tech1, tech2]
	#			}
	#			"QUICK ACTION": {[weapon1, weapon2]}
	#			"OVERHEAT": [overheatAction]
	#		}
	
	# parent_container: ActionContainer
	#	This function works recursively so the second argument is the parent container. The first 
	#	call recieves the already instanciated MainContainer
	
	# The function iterates over all elements of the dictionary. First, it creates a Button as a child
	# of the parent and an ActionContainer as a child of the button for every key on the menu_dictionary.
	# If the value for said key is an Array then the child container instanciates all action buttons.
	# If the value is a Dictionary, the function calls itself with said value as an argument and the 
	# newly created container.
	
	for menu_key in menu_dictionary:
		var value = menu_dictionary[menu_key]
		
		var child_container = ActionContainer.instance()
		var menu_button = parent_container.create_menu_button(menu_key)
		button_to_container_ref[menu_button] = child_container
		
		add_child(child_container)
		 # We set the owner to self to be able to call the emit signal function bellow directly
		child_container.set_owner(self)
		
		if typeof(value) == TYPE_DICTIONARY:
			create_menu_recursively(value, child_container)
		
		elif typeof(value) == TYPE_ARRAY:
			for action in value:
				child_container.create_action_button(action)
		child_container.hide()


func show_menu():
	main_container.show_menu()
	show()


func hide_menu():
	main_container.hide_menu()
	for child_container in get_children():
		child_container.hide_menu()
	yield(get_tree().create_timer(main_container.HIDE_SPEED), 'timeout')
	hide()


func menu_button_pressed(button_pressed: BaseUIButton, container: ActionContainer) -> void:
	var menu_to_show: ActionContainer = button_to_container_ref[button_pressed]
	menu_to_show.show_menu()

func on_action_selected(action, container: ActionContainer):
	hide_menu()
	emit_signal('action_selected', action)


