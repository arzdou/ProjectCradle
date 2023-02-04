extends Button
class_name BaseUIButton

#This padding is necessary due to the button skewness
const PAD := '   '


func _ready():
	hide()
	rect_min_size.x = 350
	rect_min_size.y = 40
	align = ALIGN_LEFT
	text = PAD + 'BUTTON'
	show()


func initialize(action_name: String) -> void:
	text = PAD + action_name
