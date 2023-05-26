extends Control


func _on_back_pressed():
	$click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	get_tree().change_scene("res://Scenes/Title Screen.tscn")


func _on_back_mouse_exited():
	$AnimationPlayer.play("RESET")


func _on_back_button_down():
	$AnimationPlayer.play("backd")


func _on_back_mouse_entered():
	$AnimationPlayer.play("backh")
