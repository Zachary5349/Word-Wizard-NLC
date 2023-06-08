extends KinematicBody2D

export var speed = 200.0
# tracks last direction
var last_dir = 0
var velocity = Vector2()
var move = true
var atk = false
var in_atk = false
var get_kb = true
var kb_modifier = 0.5
var hurt = false
var cooldown = false
signal HealthUpdate(attack_damage)

func _ready():
	if Master.current == "dragon":
		$CollisionShape2D2.disabled = false
		$CollisionShape2D.disabled = true
func _process(delta):
	velocity = Vector2()
	if move == true:
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1

	velocity = velocity.normalized()
	$AnimatedSprite.play()
	velocity = move_and_slide(velocity * speed)
	
#	position.x = clamp(position.x, 0, screen_size.x)
#	position.y = clamp(position.y, 0, screen_size.y)
	if atk == true:
		if Master.mode != "mp":
			$AnimatedSprite.animation = "atk"
			$AnimatedSprite.flip_h = velocity.x < 0
			$AnimatedSprite.flip_v = false
			yield(get_tree().create_timer(0.8),"timeout")
			atk = false
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
	
	
