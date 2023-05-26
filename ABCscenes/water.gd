extends PathFollow2D


var speed = 2
func _ready():
	unit_offset = 0.97
	$Area2D/AnimatedSprite2.frame = 0
	yield(get_tree().create_timer(0.09), "timeout")
	$Area2D/KinematicBody2D/AnimatedSprite.show()

func _process(delta):
	offset -= speed


func _on_AnimatedSprite_animation_finished():
	if $Area2D/KinematicBody2D/AnimatedSprite.animation == "splash":
		queue_free()
