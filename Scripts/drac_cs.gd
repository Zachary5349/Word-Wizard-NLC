extends Node2D


func _ready():
	$Sprite.modulate = Color(0,0,0)
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayer.play("volcano")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://ABCscenes/main.tscn")
