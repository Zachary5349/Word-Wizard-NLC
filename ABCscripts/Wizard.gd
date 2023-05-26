extends KinematicBody2D

export var speed = 30
export var bullet_speed = 1000
export var fire_rate = 0.2
# tracks last direction
var bullet_scene = preload("res://ABCscenes/bullet.tscn")
var velocity = Vector2()
var move = false
var enemy = null
var direction = Vector2.RIGHT
#func _process(delta):
#	look_at(get_global_mouse_position())
#	if Input.is_action_pressed("fire"):
#		var bullet_instance = bullet.instance()
#		bullet_instance.position = position
#		bullet_instance.rotation_degrees = rotation_degrees
#		bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
#		get_tree().get_root().add_child(bullet_instance)
		
		
func aim_fire():
	var bullet = bullet_scene.instance()
	bullet.global_position = $Position2D1.global_position
	if enemy:
		direction = enemy.global_position - global_position
	
#var target = null




	
	velocity = Vector2()
	if move == true:
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
			print("moved right")
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
			
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
			
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
			

	velocity = velocity.normalized()
	$AnimatedSprite.play()
	velocity = move_and_slide(velocity * speed)
	


func _on_AnimatedSprite_animation_finished():
#	if $AnimatedSprite.animation == "atk":
#		$AnimatedSprite.animation = "side_idle"
	pass
