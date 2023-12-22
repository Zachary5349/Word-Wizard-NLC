extends Control

#var ocean = preload("res://Scenes/Ocean.tscn")
func ready():
	$AnimationPlayer.play("RESET")
	Master.mode = "select"
func _on_drag_mouse_entered():
	if $AnimationPlayer.current_animation != "worm":
		yield(get_tree().create_timer(0.05),"timeout")
		$AnimationPlayer.play("dragon")
func _on_Kr_mouse_entered():
	if $AnimationPlayer.current_animation != "kraken":
		yield(get_tree().create_timer(0.05),"timeout")
		$AnimationPlayer.play("kraken")
func _on_wor_mouse_entered():
	if $AnimationPlayer.current_animation != "worm":
		yield(get_tree().create_timer(0.05),"timeout")
		$AnimationPlayer.play("worm")
func _on_wor_mouse_exited():
	$AnimationPlayer.play("RESET")
func _on_Kr_mouse_exited():
	$AnimationPlayer.play("RESET")
func _on_drag_mouse_exited():
	$AnimationPlayer.play("RESET")

func _on_wor_pressed():
	$start.play()
	Master.current = "worm"
	yield(get_tree().create_timer(1.15), "timeout")
	get_tree().change_scene("res://WScenes/Battle_Scene.tscn")

func _on_Kr_pressed():
	$start.play()
	Master.current = "kraken"
	yield(get_tree().create_timer(1.15), "timeout")
	get_tree().change_scene("res://Scenes/Ocean.tscn")


func _on_back_pressed():
	$click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	get_tree().change_scene("res://Scenes/Title Screen.tscn")


func _on_back_mouse_entered():
	$AnimationPlayer.play("backhover")

func _on_back_mouse_exited():
	$AnimationPlayer.play("RESET")


func _on_back_button_down():
	$AnimationPlayer.play("bdown")


func _on_drag_pressed():
	$start.play()
	Master.current = "dragon"
	yield(get_tree().create_timer(1.15), "timeout")
	get_tree().change_scene("res://ABCscenes/main.tscn")
