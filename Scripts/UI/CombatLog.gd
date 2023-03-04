extends ScrollContainer

var label_array := []

@onready var v_box_container = $VBoxContainer


func _ready() -> void:
	LogRepeater.connect("write_log",Callable(self,"write"))
	LogRepeater.connect("clear_log",Callable(self,"clear"))


func write(text: String) -> void:
	var label = Label.new()
	v_box_container.add_child(label)
	label_array.push_back(label)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = text
	scroll_vertical = get_v_scroll_bar().max_value


func clear() -> void:
	for label in label_array:
		label.queue_free()
	label_array.clear()
	
