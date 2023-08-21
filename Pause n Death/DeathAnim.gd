extends AnimatedSprite

func _ready():
	frame = 0
	yield(get_tree().create_timer(0.5), "timeout")
	play()


func _on_DeathAnim_animation_finished():
	hide()
