extends Control


func _on_back_pressed():
	$click.play()
	if Master.current == "worm" or Master.current == "kraken" or Master.current == "dragon":
		hide()
	else:
		yield(get_tree().create_timer(0.2), "timeout")
		get_tree().change_scene("res://Scenes/Title Screen.tscn")


func _on_back_mouse_entered():
	$AnimationPlayer.play("backhover")


func _on_back_mouse_exited():
	$AnimationPlayer.play("RESET")


func _on_back_button_down():
	$AnimationPlayer.play("backd")
	
