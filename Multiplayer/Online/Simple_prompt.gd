extends Control



func _on_Ok_pressed():
	get_tree().change_scene("res://Multiplayer/Arena.tscn")

func set_text(text) -> void:
	$Label.text = text
