extends Button
class_name BaseUIButton

#This padding is necessary due to the button skewness
const PAD := '   '


func _ready():
	hide()
	rect_min_size.x = 300
	rect_min_size.y = 40
	text = PAD + "BUTTON"
	align = ALIGN_LEFT


func initialize(button_name: String) -> void:
	set_name(button_name)
	text = PAD + button_name
	show()
