extends KinematicBody2D

#THIS IS ACTUALLY DARK GREEEN BTW ACTUALLY NOT RN MIGHT CHANGE
export (Color) var blue = Color("#3090C7")
#export (Color) var green = Color("#639765")
export (Color) var red = Color("#ffffff")


export (float) var speed = 0.8

var prompttransition = -1

onready var prompt = $RichTextLabel
onready var prompt_text = prompt.text

func prompttransition ():
	prompttransition = 1
 
func _ready() -> void:
#	prompttransition = get_parent().get_parent().get_parent().get_parent().transition
	
	if prompttransition == 0:
		
		prompt_text = PromptList.get_prompt()
		prompt.parse_bbcode(set_center_tags(prompt_text))
		
	else:
		prompt_text = PromptList.get_prompt2()
		prompt.parse_bbcode(set_center_tags(prompt_text))
	
	
	GlobalSignals.connect("difficulty_increased", self, "handle_difficulty_increased")
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var my_random_number = rng.randf_range(0, 10.0)
	

#
#func _physics_process(delta: float) -> void:
#	global_position.x -= speed


func set_difficulty(difficulty: int):
	handle_difficulty_increased(difficulty)


func handle_difficulty_increased(new_difficulty: int):
	var new_speed = speed + (2 * new_difficulty)
	



func get_prompt() -> String: 
	
	
	return prompt_text
	
	




func set_next_character(next_character_index: int):
	var blue_text = get_bbcode_color_tag(blue) + prompt_text.substr(0, next_character_index) + get_bbcode_end_color_tag()
	#var green_text = get_bbcode_color_tag(green) + prompt_text.substr(next_character_index, 1) + get_bbcode_end_color_tag()
	var red_text = ""

	if next_character_index != prompt_text.length():
		red_text = get_bbcode_color_tag(red) + prompt_text.substr(next_character_index , prompt_text.length() - next_character_index + 1) + get_bbcode_end_color_tag()

#	prompt.parse_bbcode(set_center_tags(blue_text + green_text + red_text))
	prompt.parse_bbcode(set_center_tags(blue_text + red_text))






func set_center_tags(string_to_center: String):
	return "[center]" + string_to_center + "[/center]"


func get_bbcode_color_tag(color: Color) -> String:
	return "[color=#" + color.to_html(false) + "]"
	return "[color=#" + color.to_html(false) + "]"
	


func get_bbcode_end_color_tag() -> String:
	return "[/color]"


func _on_transtimer_timeout():
	prompttransition = 1
