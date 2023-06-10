extends PathFollow2D

signal playerHit
signal waterHit
var info = []
var path = ""
var speed = 1
var active_enemy = null
func _ready():
	info.append(get_path())
	path = get_path()
	info.append($Area2D/Enemy.prompt_text)


func _physics_process(delta):
	look_at(Vector2(89,178))
	offset += speed * Engine.time_scale


func _on_Area2D_body_entered(body):
	if body.get_class() == "KinematicBody2D": ## &&  body in get_parent().get_parent().valid_enemies:
		get_parent().get_parent().playerHit()


func _on_Area2D_area_entered(area):
	if area.get_child(0).get_class() == "CollisionShape2D":
		area.get_parent().speed = 0.25
		area.get_child(1).get_child(1).animation = "splash"
		$Area2D/Enemy/AnimatedSprite.animation = "die"
		speed = 0.125
		yield($Area2D/Enemy/AnimatedSprite, "animation_finished")
		queue_free()
		if get_parent().get_parent().current_enemies.size() > 0:
			get_parent().get_parent().enemies.remove(get_parent().get_parent().enemies.find(get_parent().get_parent().current_enemies[0]))
			get_parent().get_parent().current_enemies.remove(0)
#		get_parent().get_parent().enemies.remove(0)
