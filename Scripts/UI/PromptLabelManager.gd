#This class connects to the LogRepeater and creates a vanishing label every time a unit takes damage 
# or recieves a status condition

extends Control
class_name PromptLabelManager

@export var TWEEN_SPEED = 0.4 # sec

const DAMAGE_TYPE_TO_LETTER = {
	0: "K",
	1: "X", 
	2: "E",
	3: "B",
	4: "H"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	LogRepeater.connect("create_prompt_label", Callable(self,"create_prompt"))
	LogRepeater.connect("create_damage_prompt_label", Callable(self,"create_damage_prompt"))


# Creates a label with a given text and position and immediately makes it disappear
func create_prompt(text: String, label_position: Vector2):
	
	var label = Label.new()
	label.hide()
	add_child(label)

	label.text = text
	label.position = label_position
	label.position -= label.size / 2 # probably a bug but it doesnt work if I substract directly
	
	label.show()
	
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(
		label, "modulate", Color(1, 1, 1, 1), TWEEN_SPEED
	).from(Color(1, 1, 1, 0))
	
	
	tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	tween.tween_property(
		label, "position", label.position + Vector2(10,-10), TWEEN_SPEED
	)
	tween.tween_property(
		label, "modulate", Color(1, 1, 1, 0), TWEEN_SPEED
	).from(Color(1, 1, 1, 1))
	await tween.finished
	
	label.queue_free()

# Creates a label with a given text and position and immediately makes it disappear
func create_damage_prompt(value: int, type: int, label_position: Vector2):
	
	var label = Label.new()
	label.hide()
	add_child(label)

	label.text = "%d %s" % [value, DAMAGE_TYPE_TO_LETTER[type]]
	label.position = label_position
	label.position -= label.size / 2 # probably a bug but it doesnt work if I substract directly
	
	label.show()
	
	var displacement = Vector2(randi()%20 - 40, -randi()%20)
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property(
		label, "position", label.position + displacement, TWEEN_SPEED * 2
	)
	tween.tween_property(
		label, "modulate", Color(1, 1, 1, 0), TWEEN_SPEED * 2
	).from(Color(1, 1, 1, 1))
	await tween.finished
	
	label.queue_free()


# Add prompts to the tree under this node. Maybe there should be a dedicated PromptMenuManager...
func _on_prompt_menu_created(prompt_menu: PromptMenu, text: String, arr: Array):
	add_child(prompt_menu)
	prompt_menu.initialize(
		text, arr
	)
	prompt_menu.position = Vector2(276, 174) # This should not be hardcoded
