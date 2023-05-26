extends Node2D


func _ready():
	yield(get_tree().create_timer(0.8), "timeout")
	$AnimationPlayer.play("New Anim")


func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://Scenes/water cutscene.tscn")
