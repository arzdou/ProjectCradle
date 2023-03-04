extends HBoxContainer
class_name StatusContainer

var status_dict: Dictionary = {
	CONSTANTS.STATUS.DANGER_ZONE: {
			"name": "Danger Zone", 
			"svg_path": "res://Media/icons/status/status_dangerzone.svg"
		},
	CONSTANTS.STATUS.ENGAGED: {
			"name": "Engaged", 
			"svg_path": "res://Media/icons/status/status_engaged.svg"
		},
	CONSTANTS.STATUS.EXPOSED: {
			"name": "Exposed", 
			"svg_path": "res://Media/icons/status/status_exposed.svg"
		},
	CONSTANTS.STATUS.HIDDEN: {
			"name": "Hidden", 
			"svg_path": "res://Media/icons/status/status_hidden.svg"
		},
	CONSTANTS.STATUS.INVISIBLE: {
			"name": "Invisible", 
			"svg_path": "res://Media/icons/status/status_invisible.svg"
		},
	CONSTANTS.STATUS.PRONE: {
			"name": "Prone", 
			"svg_path": "res://Media/icons/status/status_prone.svg"
		},
	CONSTANTS.STATUS.SHUT_DOWN: {
			"name": "Shut Down", 
			"svg_path": "res://Media/icons/status/status_shutdown.svg"
		},
}

var conditions_dict: Dictionary = {
	CONSTANTS.CONDITIONS.IMMOBILIZED: {
			"name": "Immobilized", 
			"svg_path": "res://Media/icons/conditions/condition_immobilized.svg"
		},
	CONSTANTS.CONDITIONS.IMPAIRED: {
			"name": "Impaired", 
			"svg_path": "res://Media/icons/conditions/condition_impaired.svg"
		},
	CONSTANTS.CONDITIONS.JAMMED: {
			"name": "Jammed", 
			"svg_path": "res://Media/icons/conditions/condition_jammed.svg"
		},
	CONSTANTS.CONDITIONS.LOCKED_ON: {
			"name": "Lock On", 
			"svg_path": "res://Media/icons/conditions/condition_lockon.svg"
		},
	CONSTANTS.CONDITIONS.SHREDDED: {
			"name": "Shredded", 
			"svg_path": "res://Media/icons/conditions/condition_shredded.svg"
		},
	CONSTANTS.CONDITIONS.SLOWED: {
			"name": "Slowed", 
			"svg_path": "res://Media/icons/conditions/condition_slow.svg"
		},
	CONSTANTS.CONDITIONS.STUNNED: {
			"name": "Stunned", 
			"svg_path": "res://Media/icons/conditions/condition_stunned.svg"
		},
}

const MIN_SIZE := Vector2(200, 0)

var full_label_text := ""
var glitched_letter := ""
var glitched_letter_index := 0

func _ready() -> void:
	custom_minimum_size = MIN_SIZE
	alignment = 2


func initialize(type: String, index: int) -> void:
	if type == "condition":

		full_label_text = conditions_dict[index]["name"]
		$TextureRect.texture = load(conditions_dict[index]["svg_path"])
	
	elif type == "status":
		if not status_dict.has(index):
			return
		full_label_text = status_dict[index]["name"]
		$TextureRect.texture = load(status_dict[index]["svg_path"])
	
	else:
		print("Check your input to the StatusContainer, you used type: ", type)
		return
	
	glitched_letter_index = 0
	$LetterTimer.start()
	$GlitchTimer.start()


func _on_LetterTimer_timeout():
	glitched_letter_index += 1
	



func _on_GlitchTimer_timeout():
	glitched_letter = char(randi() % 54 + 65)
	$Label.text = full_label_text.substr(0, glitched_letter_index) + glitched_letter
	
	if glitched_letter_index == len(full_label_text):
		$LetterTimer.stop()
		$GlitchTimer.stop()
		glitched_letter = ""
		glitched_letter_index += 1
		$Label.text = full_label_text.substr(0, glitched_letter_index)
