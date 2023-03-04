# Node that will manage the small HUD that moves with the unit
extends Control
class_name BarHUD

@onready var _hp_bar = $HPBar
@onready var _heat_bar = $HeatBar
@onready var _structure_bar = $StructureBar
@onready var _stress_bar = $StressBar

@export var hp: int : get = get_hp, set = set_hp
@export var heat: int : get = get_heat, set = set_heat
@export var structure: int : get = get_structure, set = set_structure
@export var stress: int : get = get_stress, set = set_stress

@export var actions: int : set = set_actions


func initialize(max_hp: int, heat_cap: int) -> void:
	_hp_bar.max_value = max_hp
	_heat_bar.max_value = heat_cap
	_structure_bar.max_value = 4
	_stress_bar.max_value = 4
	
	hp = max_hp
	heat = heat_cap
	structure = 4
	stress = 4
	
	set_actions(2)

func set_hp(new_hp: int) -> void:
	_hp_bar.value = new_hp

func set_heat(new_heat: int) -> void:
	_heat_bar.value = new_heat

func set_structure(new_structure: int) -> void:
	_structure_bar.value = new_structure

func set_stress(new_stress: int) -> void:
	_stress_bar.value = new_stress

func get_hp() -> int:
	return _hp_bar.value

func get_heat() -> int:
	return _heat_bar.value

func get_structure() -> int:
	return _structure_bar.value

func get_stress() -> int:
	return _stress_bar.value

# Hide and show the corresponding ui elements
func set_actions(value: int) -> void:
	match value:
		0:
			$HBoxContainer/action1.hide()
			$HBoxContainer/action2.hide()
			$HBoxContainer/action3.hide()
		1:
			$HBoxContainer/action1.show()
			$HBoxContainer/action2.hide()
			$HBoxContainer/action3.hide()
		2:
			$HBoxContainer/action1.show()
			$HBoxContainer/action2.show()
			$HBoxContainer/action3.hide()
		3:
			$HBoxContainer/action1.show()
			$HBoxContainer/action2.show()
			$HBoxContainer/action3.show()
		_:
			return
	actions = value
