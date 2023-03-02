extends Button
class_name BaseUIButton

#This padding is necessary due to the button skewness
const PAD := '   '

onready var h_box_container = $HBoxContainer

func _ready():
	hide()
	rect_min_size.x = 300
	rect_min_size.y = 40
	text = ""
	align = ALIGN_LEFT


func initialize(button_name: Array) -> void:
	for element in button_name:
		if typeof(element) == TYPE_STRING:
			var label = Label.new()
			h_box_container.add_child(label)
			label.text = PAD + element
			
		else:
			var texture = TextureRect.new()
			h_box_container.add_child(texture)
			texture.expand = true
			texture.stretch_mode = texture.STRETCH_KEEP_ASPECT_CENTERED
			texture.rect_min_size = Vector2(h_box_container.rect_size.y*2/3, h_box_container.rect_size.y*2/3)
			texture.texture = element
	show()
