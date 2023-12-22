extends Area2D

var hit = false
signal HealthUpdate(attack_damage)
var pos = Vector2.ZERO

func _ready():
	pos = get_parent().kraken_pos
	position.x = pos.x
func _process(delta):
	position.x = pos.x
	if hit == false:
		position.y += 3 * get_parent().slow_scale
	else:
		position.y += 0.25 * get_parent().slow_scale



func _on_Area2D_body_entered(body):
	if body.get_class() == "KinematicBody2D" && hit == false:
		hit = true
		get_node("../Player")._damage(20)
		$Hit.play()
		$AnimatedSprite.play("splash")
		yield(get_tree().create_timer(0.1), "timeout")
		z_index = 2
		yield(get_tree().create_timer(3), "timeout")
		queue_free()
