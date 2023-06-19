extends TextureProgress

var R
var G
var damage_cooldown = 0

func _ready():
	#sets the variables R and G to the current red and green values
	rect_position.x = -680
	R = $HealthBar.tint_progress.r8
	G = $HealthBar.tint_progress.g8
	
	#sets the size and position of the healthbar to a specific value in order to keep it in the same
	#position amongst different scenes
	$HealthBar.rect_size.x = 1773
	$HealthBar.rect_position.x = 11
	$HealthBar.rect_position.y = 11
	rect_size.x = 1773
	
	value = $HealthBar.value

func _process(delta):
	#sets the red and green tints of the healthbar to the current values 
	$HealthBar.tint_progress.r8 = R
	$HealthBar.tint_progress.g8 = G
	
	#if cooldown is 0 and value != the health then it reduces value 
	if damage_cooldown == 0 and value != $HealthBar.value:
		value -= (value - $HealthBar.value)/6 + .5
	elif damage_cooldown > 0:
		damage_cooldown -= 1
	
	#if dead prints dead
	if $HealthBar.value <= 0:
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene("res://Pause & Death/Death.tscn")
	elif $HealthBar.value <= 25: #starts low animations on low health
		$AnimationPlayer.play("low")
	elif $HealthBar.value <= 60: #starts shaky animation on low health
		$AnimationPlayer.play("shaky")


func _on_Player_HealthUpdate(damage):
	#detects if the health is half of the max health in which it will reduce the green value
	#if its not then it will reduce the red value. This is used in order to create a color
	#change from green to red the lower the player's health gets.
	if damage_cooldown <= 0:
		if value <= max_value/2:
			G -= 201/$HealthBar.max_value * (damage*2)
		else:
			R += 201/$HealthBar.max_value * (damage*2)
	
	#reduces the health by the amount of damage
	$HealthBar.value -= damage
	
	damage_cooldown = 50
	$AnimationPlayer2.play("hit")
	yield($AnimationPlayer2, "animation_finished")
	$AnimationPlayer2.stop()
	
	
