extends ColorRect
class_name SideBar

signal id_pressed(id)

var is_hidden := false
var is_active := false : set = _set_is_active

@onready var _hide_button = $HideButton

func _ready():
	_set_is_active(false)
	$VBoxContainer/MenuButton.get_popup().connect("id_pressed",Callable(self,"_on_item_selected"))
	

func _set_is_active(value: bool):
	if value:
		$VBoxContainer/HScrollBar.show()
		$VBoxContainer/Label.show()
		$VBoxContainer/MenuButton.show()
		$VBoxContainer/SaveButton.show()
	else:
		$VBoxContainer/HScrollBar.hide()
		$VBoxContainer/Label.hide()
		$VBoxContainer/MenuButton.hide()
		$VBoxContainer/SaveButton.hide()

func _on_item_selected(id):
	emit_signal("id_pressed", id)

func _on_HideButton_pressed():
	is_hidden = not is_hidden
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	if is_hidden:
		_hide_button.text = 'show'
		tween.tween_property(self, 'position', position+Vector2(64*4-32,0), 0.2)
	if not is_hidden:
		_hide_button.text = 'hide'
		tween.tween_property(self, 'position', position-Vector2(64*4-32,0), 0.2)
	

func _on_LoadButton_pressed():
	$VBoxContainer/Button/FileDialog.popup_centered()


func _on_SaveButton_pressed():
	$VBoxContainer/SaveButton/FileDialog.popup_centered()
