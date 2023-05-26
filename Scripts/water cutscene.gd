extends Node2D

func _ready():
	$ambient.volume_db = -23
	$bg.volume_db = -23
	$TextureRect.modulate = Color(0,0,0)
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayer.play("cut")


func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://Scenes/Ocean.tscn")
