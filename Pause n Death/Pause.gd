extends Node


var timescale = 1;
var shown = false


func _ready():
	$ColorRect.hide()
	shown = false

func _process(delta):
	if Master.current == "worm":
		$ColorRect/Label.text = "press enter near a spire to open it\n\nUnscramble each word on the spire to activate it\n\navoid the worm\n\nactivate all 3 spires to defeat the worm!"
	if Master.current == "kraken":
		$ColorRect/Label.text = "get across the ocean using the planks\n\nclick on a plank to build a bridge towards it\ncreate a word with the bridge's distance\n\navoid the water blasts from the kraken"
	if Master.current == "dragon":
		$ColorRect/Label.text = "the dragon will attack you with fireballs, it is your job to extinguish them\n\nyou can cast a water blast by typing the word underneath the fireball\n\nmake sure to type fast or the fireballs will hit!"

func _on_Quit_pressed():
	$click.play()
	get_tree().quit()


func _on_Controls_pressed():
	$click.play()
	$Control.visible = true


func _on_Main_Menu_pressed():
	$click.play()
	Engine.time_scale = 1
	get_tree().change_scene("res://Scenes/Title Screen.tscn")


func _input(event):
	if Input.is_action_just_pressed("space"):
		vis_toggle()
		shown = true


func _on_Resume_pressed():
	$click.play()
	vis_toggle()
	shown = false

func vis_toggle():
	if $ColorRect.visible:
		$ColorRect.hide()
		Engine.time_scale = timescale
	else:
		$ColorRect.show()
		timescale = Engine.time_scale
		Engine.time_scale = 0.001


func _on_Instr_pressed():
	$ColorRect/VBoxContainer.hide()
	$ColorRect/Quit.hide()
	$ColorRect/back.show()
	$ColorRect/Label.show()
	$ColorRect/Label.visible = true


func _on_back_pressed():
	$ColorRect/VBoxContainer.show()
	$ColorRect/Quit.show()
	$ColorRect/back.hide()
	$ColorRect/Label.hide()
	$ColorRect/Label.visible = false
	
