extends VBoxContainer

const StatusContainer: PackedScene = preload("res://Scenes/Unit/UnitHUD/StatusContainer.tscn")

func set_from_dict(status_dict: Dictionary, condition_dict: Dictionary) -> void:
	clear()
	
	for status_index in status_dict:
		if status_dict[status_index]:
			add_status(status_index)
	
	for condition_index in condition_dict:
		if condition_dict[condition_index]:
			add_condition(condition_index)

func add_status(status_index: int) -> void:
	var status_container := StatusContainer.instantiate()
	add_child(status_container)
	status_container.initialize("status", status_index)
		

func add_condition(condition_index: int) -> void:
	var condition_container := StatusContainer.instantiate()
	add_child(condition_container)
	condition_container.initialize("condition", condition_index)

func clear():
	for n in get_children():
		remove_child(n)
		n.queue_free()
