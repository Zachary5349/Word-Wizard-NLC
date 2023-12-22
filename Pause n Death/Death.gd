extends Node


func _ready():
	
	Engine.time_scale = 1
	

func _on_MainMenu_pressed():
	$click.play()
	get_tree().change_scene("res://Scenes/Title Screen.tscn")


func _on_NewGame_pressed():
	$start.play()
	if Master.mode == "story":
		yield(get_tree().create_timer(1.15), "timeout")
		Master.start_time = OS.get_unix_time()
		get_tree().change_scene("res://Scenes/Main_cutscene.tscn")
	else:
		if Master.current == "worm":
			get_tree().change_scene("res://WScenes/Battle_Scene.tscn")
		elif Master.current == "kraken":
			get_tree().change_scene("res://Scenes/Ocean.tscn")
		elif Master.current == "dragon":
			get_tree().change_scene("res://ABCscenes/main.tscn")
