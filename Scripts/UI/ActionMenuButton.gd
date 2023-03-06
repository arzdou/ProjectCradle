# Small button with an icon that shows a label on top when its hovered
extends Button
class_name ActionMenuButton

# The name of the button is displayed under the button when is hovered
@onready var label = $Label

func _ready():
	$Label.hide()
	size = Vector2(50, 50)

func initialize(button_name: String, button_texture: Texture):
	if button_name:
		name = button_name
		label.text = button_name
		label.position.x = -label.size.x/2 + size.x/2
	
	if button_texture:
		icon = button_texture

# Show the label with text on top
func _on_mouse_entered():
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(label, "modulate", Color(1,1,1,1), 0.1).from(Color(1,1,1,0))
	label.show()

# Hide the label
func _on_mouse_exited():
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(label, "modulate", Color(1,1,1,0), 0.1).from(Color(1,1,1,1))
	await tween.finished
	label.hide()
