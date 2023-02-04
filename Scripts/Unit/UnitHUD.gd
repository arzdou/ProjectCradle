# Node that will manage the small HUD that moves with the unit
extends Node2D
class_name UnitHUD

onready var _hp_bar = $HPBar
onready var _heat_bar = $HeatBar
onready var _structure_bar = $StructureBar
onready var _stress_bar = $StressBar

export var hp: int setget set_hp
export var heat: int setget set_heat
export var structure: int setget set_structure
export var stress: int setget set_stress


func initialize(max_hp: int, heat_cap: int) -> void:
	_hp_bar.max_value = max_hp
	_heat_bar.max_value = heat_cap
	_structure_bar.max_value = 4
	_stress_bar.max_value = 4
	
	hp = max_hp
	heat = heat_cap
	structure = 4
	stress = 4

func set_hp(new_hp: int) -> void:
	_hp_bar.value = new_hp

func set_heat(new_heat: int) -> void:
	_heat_bar.value = new_heat

func set_structure(new_structure: int) -> void:
	_structure_bar.value = new_structure

func set_stress(new_stress: int) -> void:
	_stress_bar.value = new_stress


