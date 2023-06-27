extends Control


func _on_back_pressed():
	$Control/click.play()
	if Master.current == "worm" or Master.current == "kraken" or Master.current == "dragon":
		hide()
	else:
		yield(get_tree().create_timer(0.2), "timeout")
		get_tree().change_scene("res://Scenes/Title Screen.tscn")


func _on_back_mouse_entered():
	$Control/back/AnimationPlayer.play("backhover")


func _on_back_mouse_exited():
	$Control/back/AnimationPlayer.play("RESET")


func _on_back_button_down():
	$Control/back/AnimationPlayer.play("backd")
	


func _on_Button_pressed():
	$Control2.hide()
	


func _on_Button2_pressed():
	$Control2.show()
