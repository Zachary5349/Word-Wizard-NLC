extends Node


var timescale = 1;


func _ready():
	$ColorRect.hide()


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


func _on_Resume_pressed():
	$click.play()
	vis_toggle()


func vis_toggle():
	if $ColorRect.visible:
		$ColorRect.hide()
		Engine.time_scale = timescale
	else:
		$ColorRect.show()
		timescale = Engine.time_scale
		Engine.time_scale = 0.001
