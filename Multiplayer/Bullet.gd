extends KinematicBody2D

var velocity = Vector2(0, 1)
var speed = 300
var target = Vector2.ZERO
var hits = 0
#func _ready():
#	yield(get_tree().create_timer(0.1), "timeout")

func _physics_process(delta):
	var collision_info = move_and_collide(velocity.normalized() * delta * speed)

func _on_Area2D_body_exited(body):
	$CollisionShape2D.disabled = false


func _on_Area2D_body_entered(body):
	hits += 1
	if hits == 2:
		if body.name.substr(0,6) == "Player":
			body._damage(30)
		queue_free()
