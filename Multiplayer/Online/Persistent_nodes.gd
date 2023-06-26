extends Node


func _process(delta):
	if $CanvasLayer/Label.text != "":
		yield(get_tree().create_timer(1.5), "timeout")
		$CanvasLayer/Label.text = ""
#		for node in get_children():
#			if node.is_in_group("OnlinePlayer"):
#				node.queue_free()
#			else:
#				node.hide()
		get_tree().change_scene("res://Scenes/Title Screen.tscn")
