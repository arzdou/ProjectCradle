extends ScrollContainer

var label_array := []


func _ready() -> void:
	LogRepeater.connect("update_log", self, "write_log")
	LogRepeater.connect("clear_log", self, "clear_log")


func write_log(text: String) -> void:
	var label = Label.new()
	$VBoxContainer.add_child(label)
	label_array.push_back(label)
	label.text = text


func clear_log() -> void:
	for label in label_array:
		label.queue_free()
	label_array.clear()
	
