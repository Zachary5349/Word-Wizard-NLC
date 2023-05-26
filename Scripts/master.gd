extends Node


var start_time = OS.get_unix_time()
var current = "title"
var mode = "title"
func _ready():
	SilentWolf.configure({
		"api_key": "eKFbtGHb9a5AsYsiwdPfvaWHjEIa2qe9aHfgOZOW",
		"game_id": "wordwizard",
		"game_version": "1.0.0",
		"log_level": 0
	})
	SilentWolf.configure_scores({
		"open_scene_one_close": "res://Scenes/Title Screen.tscn"
	})

#make esc the key to quit the game

func _input(event: InputEvent):
	if Input.is_action_pressed("esc"):
		get_tree().quit()
