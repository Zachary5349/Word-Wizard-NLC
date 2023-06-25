extends Node2D

var player_following = null
var text = "" setget text_set

onready var label = $Label

func _process(delta: float) -> void:
	
	if player_following != null and (is_instance_valid(player_following)):
		global_position = player_following.global_position
		
func text_set(new_text) -> void:
	text = new_text
	label.text = text
