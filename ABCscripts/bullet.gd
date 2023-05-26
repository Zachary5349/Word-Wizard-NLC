extends KinematicBody2D


#var direction = Vector2.RIGHT
#var speed = 400


		

	
#func _physics_process(delta):
	#translate(direction * speed * delta) 
	#if target:
		#direction = target.global_position - global_position 
		#direction = direction.normalized()
		#look_at(target.global_position)
		

#func _physics_process(delta: float) -> void:
#		if not _target:
#			position += max_speed * Vector2.RIGHT.rotated(rotation) * delta
#			return

#func _on_RigidBody2D_body_exited(body):
	#if body.is_in_group("enemy"):
	#	pass
	#queue_free()
	

 
#func _on_aiming_area_body_exited(body):
	#target = body


#func _on_VisibilityNotifier2D_screen_exited():
	#queue_free()
