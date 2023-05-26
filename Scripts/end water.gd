extends Node2D


func _ready():
	$Label.percent_visible = 0
	$Sprite.modulate = Color(0,0,0)
	yield(get_tree().create_timer(0.5), "timeout") # wait 0.5 seconds to start animaton, so it isn't immediate
	$AnimationPlayer.play("water")


func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://Scenes/dragon_cs.tscn") # switch to dragon intro cutscene
