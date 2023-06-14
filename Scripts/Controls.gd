extends Control


func _on_back_pressed():
	$click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	get_tree().change_scene("res://Scenes/Title Screen.tscn")


func _on_back_mouse_entered():
	$back/AnimationPlayer.play("backhover")


func _on_back_mouse_exited():
	$back/AnimationPlayer.play("RESET")


func _on_back_button_down():
	$back/AnimationPlayer.play("backd")
	
