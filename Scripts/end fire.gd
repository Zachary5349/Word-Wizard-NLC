extends Node2D

var  total_time = 0 # holds time the player took to complete game
var  minutes = 0
var seconds = 0

func _ready():
	# gets current time of operating system and subtracts from start time to get the total time in seconds
	var finish_time = OS.get_unix_time() 
	total_time = finish_time - Master.start_time
	# convert time from seconds to get mm:ss format
	minutes = (total_time/60)
	seconds = (total_time%60)
	# used to add 0 in front of seconds to create :01 instead of :1
	if seconds < 10:
		seconds = "0" + str(seconds)
	$Sprite2.visible = 2
	$AnimationPlayer.play("create")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "create":
		$AnimationPlayer.play("wand") # switch animations


func _on_title_pressed():
	get_tree().change_scene("res://Scenes/Title Screen.tscn") # change to Title Screen


func _on_submit_pressed():
	var name = $Sprite/Control/TextureRect/LineEdit.text # stores 
	
	SilentWolf.Scores.persist_score(name, total_time) # upload name and time into leaderboard server and (orders by totaltime in seconds)
#	SilentWolf.Scores.get_high_scores()
	$Sprite/Control/TextureRect/Label3.text = "Thank you for submitting!"
	# rearrange buttons
	$Sprite/Control/TextureRect/title.margin_top = -19
	$Sprite/Control/TextureRect/title.margin_bottom = 34
	$Sprite/Control/TextureRect/LineEdit.hide()
	$Sprite/Control/TextureRect/submit.hide()


func _on_leaderboard_pressed():
	# hide finish screen
	$Sprite/Control.visible = false
	# show leaderboard
	$Sprite/ReverseLeaderboard.visible = true
