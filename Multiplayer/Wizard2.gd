extends KinematicBody2D

export var speed = 200.0
# tracks last direction
var last_dir = 0
var velocity = Vector2()
var move = true
var atk = false
var get_kb = true
var kb_modifier = 0.5
var hurt = false
var cooldown = false

const bulletPath = preload("res://Multiplayer/Bullet.tscn")

signal HealthUpdate(attack_damage)


func _process(delta):
	velocity = Vector2()
	if move == true:
		if Input.is_action_pressed("move_right2"):
			velocity.x += 1
		if Input.is_action_pressed("move_left2"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down2"):
			velocity.y += 1
		if Input.is_action_pressed("move_up2"):
			velocity.y -= 1

	velocity = velocity.normalized()
	$AnimatedSprite.play()
	velocity = move_and_slide(velocity * speed)
	
#	position.x = clamp(position.x, 0, screen_size.x)
#	position.y = clamp(position.y, 0, screen_size.y)
	if atk == true:
		pass
	elif hurt == true:
		$AnimatedSprite.animation = "hurt"
		$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.flip_v = false
		yield(get_tree().create_timer(0.15),"timeout")
		hurt = false
	elif velocity.x != 0:
		$AnimatedSprite.animation = "siderun"
		$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.flip_v = false
		last_dir = 2
	elif velocity.y < 0:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "backrun"
		last_dir = 1
	elif velocity.y > 0:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "frontrun"
		last_dir = 0
	else:
		if last_dir == 0:
			$AnimatedSprite.animation = "frontidle"
		elif last_dir == 1: 
			$AnimatedSprite.animation = "backidle"
		else:
			$AnimatedSprite.animation = "sideidle"
	if $AnimatedSprite.flip_h:
		$AnimatedSprite/Area2D.scale.x = 1
	else:
		$AnimatedSprite/Area2D.scale.x = -1

func _damage(dmg):
	emit_signal("HealthUpdate", dmg)
#	if move == false:
#		get_parent()._hide()
	hurt = true
#func _knockback(damage_source_pos, recieved_dmg):
#	if get_kb:
#		var kb_dir = damage_source_pos.direction_to(global_position)
#		var kb_strength = recieved_dmg * kb_modifier
#		var knockback = kb_dir * kb_strength
#		global_position.x = lerp(global_position.x, (global_position.x + 30), 0.5)
##		global_position.y = lerp(global_position.y, knockback.y, 0.01)
	
func shoot(target_pos):
	var bullet = bulletPath.instance()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.look_at(target_pos)
	bullet.velocity = target_pos - bullet.global_position
	
	
func _input(event):
	if move == true:
		if event.is_action_pressed("atk2") && !cooldown && get_parent().p2_shots > 0:
			shoot((get_parent().get_node("Player1")).global_position)
			get_parent().p2_shots -= 1
			atk = true
			cooldown = true
			$AnimatedSprite.animation = "atk"
			$AnimatedSprite.flip_h = velocity.x < 0
			$AnimatedSprite.flip_v = false
			yield(get_tree().create_timer(0.8),"timeout")
			atk = false
			cooldown = false
		elif event.is_action_pressed("melee2") && !cooldown:
			cooldown = true
			atk = true
			$AnimatedSprite.animation = "melee"
			yield(get_tree().create_timer(0.17), "timeout")
			$AnimatedSprite/Area2D/CollisionPolygon2D.disabled = false
			yield(get_tree().create_timer(0.25), "timeout")
			$AnimatedSprite/Area2D/CollisionPolygon2D.disabled = true
			yield(get_tree().create_timer(0.15),"timeout")
			cooldown = false


func _on_Area2D_body_entered(body):
	if body.name == "Player1":
		body._damage(15)


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "melee":
		atk = false
