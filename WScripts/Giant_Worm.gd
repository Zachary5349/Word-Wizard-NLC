extends KinematicBody2D

var velocity = Vector2.ZERO
var player = null
var attack = false
var lock = false
var once = false
var attack_phase = 0
var lock_area = Vector2.ZERO
var rock_list = []
var once2 = false
var target_list = []
var rock_count = 6
var target_pos = 0
var spikes = preload("res://WScenes/Spikes.tscn")
signal attack(attack_damage)
var health = 3

func _ready():
	randomize()
	$CollisionShape2D.disabled = true
	$YSort/AnimatedSprite.play("idle")


func _process(delta):
	#if the boss isnt dead
	if health > 0:
		#Checks if the player's y value is less than the target's y value, in which the rock will then 
		#appear infront of the player. Otherwise the rock will appear infront of the player.
		for rock in rock_list:
			if player.y-5 < rock.target_global.y:
				rock.z_index = 1
			else:
				rock.z_index = 0
		
		#detects if the player doesn't equal null, in which case the main code of the boss will run 
		#in order to prevent crashing if the player doesn't exist.
		if player and health > 0:
			if not attack:
				#when the player is 50 pixels away the boss will teleport to the player the nbegin its attack phase
				if sqrt((player.x-position.x)*(player.x-position.x) + (player.y-position.y)*(player.y-position.y)) <= 50:
					attack = true
					lock = true
					velocity = Vector2.ZERO
					$AttackTimer.start()
					lock_area.x = player.x
					lock_area.y = player.y+2
				
				#while the boss isn't it it's attack phase, it will slowly chase the player at a speed of 50 pixels/s
				velocity = position.direction_to(player)*50
				move_and_collide(velocity * delta)
			
			#used to keep the boss in position during its attack phase
			if lock:
				position.x = clamp(position.x, lock_area.x, lock_area.x)
				position.y = clamp(position.y, lock_area.y, lock_area.y)
			
			#manages the boss launching rocks towards the selected area whilist enabling visibility 
			#on the target sprites
			if attack_phase == 1 and not once:
				$AttackTimer2.start()
				$YSort/AnimatedSprite.play("default")
				$YSort/AnimatedSprite.frame = 0
				$burst_noise.play(6.9)
				var spike = spikes.instance()
				spike.name = "spikes"
				spike.offset = $YSort/AnimatedSprite.offset + Vector2(10,-30)
				spike.scale = $YSort/AnimatedSprite.scale
				spike.z_index = $YSort/AnimatedSprite.z_index
				add_child(spike, true)
				target_pos = randf();
				for num in range(0,rock_count):
					target()
				for trget in target_list:
					rock(trget.position, trget.global_position)
				#if the player is within a certain distance upon exiting the ground, the player gets hit.
				if sqrt((player.x-position.x)*(player.x-position.x) + (player.y-position.y)*(player.y-position.y)) <= 38:
					emit_signal("attack", 17)
				$CollisionShape2D.disabled = false
				once = true
			
			#removes each rock once the second timer ends
			elif attack_phase == 2 and not once2:
				$burst_noise.stop()
				for rocks in rock_list:
#					rocks.move = false
#					print(rocks.move)
#					
					if sqrt(pow(float(player.x - rocks.target_global.x), 2.0) + pow(float(player.y - rocks.target_global.y), 2.0)) <= 45.0:
						emit_signal("attack", 10)
					rocks.get_node("AnimatedSprite").play("break")
#					remove_child(rocks)
				rock_list = []
				for trget2 in target_list:
					remove_target(trget2)
#				target_list = []
				$AttackTimer3.start()
				once2 = true
			
			#allows the boss to attack once the final timer ends
			elif attack_phase == 3:
				$YSort/AnimatedSprite.play("idle")
				lock = false
				attack_phase = 0
				attack = false
				once = false
				once2 = false
				$CollisionShape2D.disabled = true
	elif health == 0: #if the boss hits 0 health (this is done so it doesnt repeat forever)
		$YSort/AnimatedSprite.play("stun")
		$YSort/AnimatedSprite.frame = 0
		#reduces health for reason above
		health -= 1
		#adds a spike one last time
		var spike = spikes.instance()
		spike.name = "spikes"
		spike.offset = $YSort/AnimatedSprite.offset + Vector2(10,-30)
		spike.scale = $YSort/AnimatedSprite.scale
		spike.z_index = $YSort/AnimatedSprite.z_index
		add_child(spike, true)
		$stun_noise.play()
		$stun_noise.volume_db = -10

#sets it to the first phase after 1 second has passed
func _on_AttackTimer_timeout():
	attack_phase = 1

#creates a new rock and sets the target and target's global positions to the varibles given
func rock(target, global_pose):
	var rock = load("res://WScenes/rock.tscn")
	var new_rock = rock.instance()
	new_rock.target = target
	new_rock.target_global = global_pose
	add_child(new_rock, true)
	rock_list.append(new_rock)

#creates a new target and sets it target position
func target():
	var target = load("res://WScenes/RockTarget.tscn")
	var new_target = target.instance()
	var target_path = $YSort/TargetPath/TargetPathFollow
	target_path.unit_offset = target_pos
	target_pos += 1.0/rock_count
	if target_pos > 1:
		target_pos -= 1
	new_target.position = target_path.position
	add_child(new_target, true)
	target_list.append(new_target)
	

#sets it to the second phase after 2.5 seconds
func _on_AttackTimer2_timeout():
	attack_phase  = 2

#sets it to the last phase after .75 seconds
func _on_AttackTimer3_timeout():
	attack_phase = 3

#when a spike object enteres the scene it wats 2.45 seconds then kills it
func _on_Giant_Worm_child_entered_tree(node):
	if node.name.substr(0,6) == "spikes":
		node.frame = 0
#		print("here")
		yield(get_tree().create_timer(2.45), "timeout")
		node.queue_free()
		
		
func remove_target(node):
	yield(get_tree().create_timer(0.5), "timeout")
	print("fdgdfg")	
	node.queue_free()
	target_list.remove(0)
