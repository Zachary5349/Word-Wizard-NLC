tool
extends Node2D

const ScoreItem = preload("res://addons/silent_wolf/Scores/ScoreItem.tscn")
const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

var list_index = 0
var ld_name = "main"

var  total_time = 0
var  minutes = 0
var seconds = 0


func _ready():
	var scores = []
#	if ld_name in SilentWolf.Scores.leaderboards:
#		scores = SilentWolf.Scores.leaderboards[ld_name]
#
#	if len(scores) > 0: 
#		render_board(scores)
#	else:
	# use a signal to notify when the high scores have been returned, and show a "loading" animation until it's the case...
	add_loading_scores_message()
	yield(SilentWolf.Scores.get_high_scores(0), "sw_scores_received")
	hide_message()
	render_board(SilentWolf.Scores.scores)


func render_board(scores):
	if !scores:
		add_no_scores_message()
	else:
		if len(scores) > 1 and scores[0].score > scores[-1].score:
			scores.invert()
		for i in range(len(scores)):
			var score = scores[i]
			add_item(score.player_name, str(int(score.score)))
			#var time = display_time(scores[i].score)
			#add_item(score.player_name, time)


#func display_time(time_in_millis):
#	var minutes = int(floor(time_in_millis / 60000))
#	var seconds = int(floor((time_in_millis % 60000) / 1000))
#	var millis = time_in_millis - minutes*60000 - seconds*1000
#	var displayable_time = str(minutes) + ":" + str(seconds) + ":" + str(millis)
#	return displayable_time


func reverse_order(scores):
	var reverted_scores = scores
	if len(scores) > 1 and scores[0].score > scores[-1].score:
		reverted_scores = scores.invert()
	return reverted_scores

	
func sort_by_score(a, b):
	if a.score > b.score:
		return true;
	else:
		if a.score < b.score:
			return false;
		else:
			return true;


func add_item(player_name, score):
	var item = ScoreItem.instance()
	list_index += 1
	minutes = (int(score)/60)
	seconds = (int(score)%60)
	if minutes < 10:
		minutes = "0" + str(minutes)
	if seconds < 10:
		seconds = "0" + str(seconds)
	if list_index == 1:
		$Control/ScrollContainer/Scores.text += str(list_index) + str(".        ") + player_name
		$Control/ScrollContainer/Scores/Time.text += str(minutes) + ":" + str(seconds) + "        "
		
	else:
		$Control/ScrollContainer/Scores.text += "\n" + str(list_index) + str(".     ") + player_name
		$Control/ScrollContainer/Scores/Time.text += "\n" + str(minutes) + ":" + str(seconds) + "        "


func add_no_scores_message():
	var item = $"Control/TextMessage"
	item.text = "No scores yet!"
	$"Control/TextMessage".show()


func add_loading_scores_message():
	var item = $"Control/TextMessage"
	item.text = "Loading scores..."
	$"Control/TextMessage".show()


func hide_message():
	$"Control/TextMessage".hide()
	
	
func _on_CloseButton_pressed():
	var scene_name = SilentWolf.scores_config.open_scene_on_close
	print("scene_name: " + str(scene_name))
	get_tree().change_scene(scene_name)


func _on_title_pressed():
	$click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	get_tree().change_scene("res://Scenes/Title Screen.tscn")
