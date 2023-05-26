extends Node


func _ready():
	$CanvasLayer/AnimationPlayer.play("volcano up")
	Master.mode = "story"

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://Scenes/worm_cs.tscn")
