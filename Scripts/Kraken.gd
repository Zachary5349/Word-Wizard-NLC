extends KinematicBody2D


onready var player = get_node("../Player")
var movement_speed = 2
var follow = false

var blast = preload("res://Scenes/Water_blast.tscn")
var can_fire = true
var time_between_fire = 4

func _physics_process(delta):
	# once player passes kraken's original position, start following player
	if player.global_position.x >= 103:
		follow = true
	if follow == true:
		global_position.x = lerp(global_position.x, player.global_position.x, movement_speed * delta) # need delta
		if can_fire == true:
			can_fire = false
			var blast_instance = blast.instance()
			$AnimatedSprite.animation = "shoot"
			yield($AnimatedSprite, "animation_finished")

			blast_instance.global_position.x = global_position.x
			blast_instance.global_position.y = global_position.y + 30
			get_parent().add_child(blast_instance)
			$AnimatedSprite.animation = "shoot_final"
			$AnimatedSprite.animation = "default"
			time_between_fire -= 0.15
			yield(get_tree().create_timer(time_between_fire), "timeout")
			can_fire = true
