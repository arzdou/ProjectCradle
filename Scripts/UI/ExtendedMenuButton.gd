# Small button with an icon that shows a label on top when its hovered
extends Button
class_name ExtendedMenuButton

@onready var name_label = $MarginContainer/AspectRatioContainer/VBoxContainer/NameLabel
@onready var damage_range_label = $MarginContainer/AspectRatioContainer/VBoxContainer/DamageRangeLabel
@onready var tags_label = $MarginContainer/AspectRatioContainer/VBoxContainer/TagsLabel
@onready var cost_icon1 =$MarginContainer/AspectRatioContainer/VBoxContainer2/CostIcon1
@onready var cost_icon2 =$MarginContainer/AspectRatioContainer/VBoxContainer2/CostIcon2


func _ready():
	size = Vector2(150, 50)

func initialize(action: BaseAction):
	if not action:
		return
	name = action.name
	name_label.text = action.name
	
	var tag_string := "tag"
	for tag in action.tag:
		tag_string += tag.name + ", "
	tags_label.text = tag_string
	
	if action.no_attack:
		damage_range_label.text = "no damage" 
		return
		
	var dres = action.damage[0]
	var damage_string = "%dd%d" % [dres.number_of_dices, dres.dice_faces]
	if dres.constant_damage > 0:
		damage_string+="+%d"%dres.constant_damage
	damage_string += "%d" % dres.type
	
	var rres = action.ranges[0]
	var range_string = "%d%d" % [rres.range_value, rres.type]
	damage_range_label.text = damage_string + " - " + range_string
	
	# Show 0, 1 or 2 cost icons on the right side of the menu
	match action.cost:
		0:
			cost_icon1.hide()
			cost_icon2.hide()
		1:
			cost_icon1.show()
			cost_icon2.hide()
		2:
			cost_icon1.show()
			cost_icon2.show()

# Show the label with text on top
func _on_mouse_entered():
	#var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	pass

# Hide the label
func _on_mouse_exited():
	#var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	pass
