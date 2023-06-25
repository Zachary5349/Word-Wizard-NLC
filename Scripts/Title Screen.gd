#trying out git branches - gitDemo branch
#testing git 4 zach pls work

extends Control

var cursor = load("res://Assets/title/cursor.png")
var start_time

func _ready():
#	get_tree().change_scene("res://Multiplayer/Online/Network_Setup.tscn")
#	SilentWolf.Scores.persist_score("xmandubs", 432)
#	SilentWolf.Scores.persist_score("rockhold", 349)
#	SilentWolf.Scores.persist_score("Iluvfbla", 357)
#	SilentWolf.Scores.persist_score("zjw", 401)
#	SilentWolf.Scores.persist_score("brimstone", 543)
#	SilentWolf.configure({
#		"api_key": "eKFbtGHb9a5AsYsiwdPfvaWHjEIa2qe9aHfgOZOW",
#		"game_id": "wordwizard",
#		"game_version": "1.0.0",
#		"log_level": 0
#	})
#	SilentWolf.configure_scores({
#		"open_scene_one_close": "res://Scenes/Title Screen.tscn"
#	})
	Input.set_custom_mouse_cursor(cursor)
	Master.mode = "title"


func _on_NewGame_mouse_entered():
	hover()
func _on_LevelSelect_mouse_entered():
	hover()
func _on_Leaderboard_mouse_entered():
	hover()
func _on_Controls_mouse_entered():
	hover()
func _on_Credits_mouse_entered():
	hover()
func _on_Exit_mouse_entered():
	hover()
	
func _on_NewGame_mouse_exited():
	exit()
func _on_LevelSelect_mouse_exited():
	exit()
func _on_Leaderboard_mouse_exited():
	exit()
func _on_Controls_mouse_exited():
	exit()
func _on_Credits_mouse_exited():
	exit()
func _on_Exit_mouse_exited():
	exit()
func hover():
	$AnimationPlayer.play("start_hover")
func exit():
	$AnimationPlayer.play("end_hover")


func _on_NewGame_pressed():
	$start.play()
	yield(get_tree().create_timer(1.15), "timeout")
	Master.start_time = OS.get_unix_time()
	get_tree().change_scene("res://Scenes/Main_cutscene.tscn")


func _on_LevelSelect_pressed():
	$start.play()
	yield(get_tree().create_timer(1.15), "timeout")
	Master.mode = "select"
	get_tree().change_scene("res://Scenes/LevelSelect.tscn")


func _on_Leaderboard_pressed():
	$start.play()
	yield(get_tree().create_timer(1.15), "timeout")
	get_tree().change_scene("res://Scenes/HomeLeaderboard.tscn")


func _on_Controls_pressed():
	$click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	get_tree().change_scene("res://Scenes/Controls.tscn")


func _on_Credits_pressed():
	$click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	get_tree().change_scene("res://Scenes/Credits.tscn")


func _on_Exit_pressed():
	$click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	get_tree().quit()


func _on_Multiplayer_pressed():
	$start.play()
	yield(get_tree().create_timer(1.15), "timeout")
	get_tree().change_scene("res://Multiplayer/Arena.tscn")
