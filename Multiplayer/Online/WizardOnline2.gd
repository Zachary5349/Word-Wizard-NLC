extends KinematicBody2D

export var speed = 200.0
# tracks last direction
var last_dir = 0
var velocity = Vector2()

var hp = 100 setget set_hp
var move = true
var atk = false
var get_kb = true
var kb_modifier = 0.5
var hurt = false
var cooldown = false
var can_shoot = false
var melee = false
var shots = 0

puppet var puppet_hp = 100 setget puppet_hp_set
puppet var puppet_position = Vector2(0,0) setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0
puppet var puppet_username = "" setget puppet_username_set

const player_bullet = preload("res://Multiplayer/Online/Online_Bullet.tscn")

var username_text = load("res://Multiplayer/Online/Username_text.tscn")

var username setget username_set
var username_text_instance = null

onready var sprite = $AnimatedSprite
onready var shoot_point = $Position2D

signal HealthUpdate(attack_damage)

func _ready():
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	
	username_text_instance = Global. instance_node_at_location(username_text, Persistent_Nodes, global_position)
	username_text_instance.player_following = self
	
	can_shoot = false
	
	yield(get_tree(), "idle_frame")
	if is_network_master():
		Global.player_master = self

func _process(delta):
	if username_text_instance != null and is_instance_valid(username_text_instance):
		username_text_instance.name = "username" + name
	if is_network_master() and visible:
		for node in get_parent().get_children():
			if node.is_in_group("OnlinePlayer") and not node == self:
				node.rpc("_anim")
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
		velocity = move_and_slide(velocity * speed)
		
		$Sprite.look_at(get_global_mouse_position())
		
		if Input.is_action_pressed("shoot") and can_shoot and not cooldown and shots >= 1:
			shots -= 1
			rpc("instance_bullet", get_tree().get_network_unique_id())
			cooldown = true
			atk = true
			$AnimatedSprite.animation = "atk"
			$AnimatedSprite.flip_h = velocity.x < 0
			$AnimatedSprite.flip_v = false
			$Reload_timer.start()
		if Input.is_action_pressed("melee1"):
			cooldown = true
			melee = true
			$AnimatedSprite.animation = "melee"
			yield(get_tree().create_timer(0.17), "timeout")
			$AnimatedSprite/Area2D/CollisionPolygon2D.disabled = false
			yield(get_tree().create_timer(0.25), "timeout")
			$AnimatedSprite/Area2D/CollisionPolygon2D.disabled = true
			melee = false
			yield(get_tree().create_timer(0.15),"timeout")
			cooldown = false
		
	else:
		rotation_degrees = lerp(rotation_degrees, puppet_rotation, delta * 8)
		
		if not $Tween.is_active():
			move_and_slide(puppet_velocity * speed)
	#	position.x = clamp(position.x, 0, screen_size.x)
	#	position.y = clamp(position.y, 0, screen_size.y)
	if hp <= 0:
		can_shoot = false
		rpc("hit_by_damager", 100)
		if username_text_instance != null and is_instance_valid(username_text_instance):
			username_text_instance.visible = false
		$AnimatedSprite.animation = "die"
		yield($AnimatedSprite, "animation_finished")
#		get_parent().get_node("CanvasLayer/Label").show()
#		get_parent().get_node("CanvasLayer/Label").text = Master.user1 + "wins!"
#		for node in get_parent().get_children():
#			if node.is_in_group("2"):
#				Persistent_Nodes.get_node("CanvasLayer/Label").show()
#				Persistent_Nodes.get_node("CanvasLayer/Label").text = node.username + " wins!"
		if is_network_master():
			Global.player_master = null
		queue_free()

	rpc("_anim")
	




	
#func _input(event):
#	if is_network_master():
#		if move == true:
#			if event.is_action_pressed("atk1") && !cooldown: # && get_parent().p1_shots > 0:
#				shoot((get_parent().get_node("Player2")).global_position)
##				get_parent().p1_shots -= 1
#				atk = true
#				cooldown = true
#				$AnimatedSprite.animation = "atk"
#				$AnimatedSprite.flip_h = velocity.x < 0
#				$AnimatedSprite.flip_v = false
#				yield(get_tree().create_timer(0.8),"timeout")
#				atk = false
#				cooldown = false
#			elif event.is_action_pressed("melee1") && !cooldown:
#				cooldown = true
#				atk = true
#				$AnimatedSprite.animation = "melee"
#				yield(get_tree().create_timer(0.17), "timeout")
#				$AnimatedSprite/Area2D/CollisionPolygon2D.disabled = false
#				yield(get_tree().create_timer(0.25), "timeout")
#				$AnimatedSprite/Area2D/CollisionPolygon2D.disabled = true
#				yield(get_tree().create_timer(0.15),"timeout")
#				cooldown = false


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "melee" || "atk":
		atk = false

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	$Tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	$Tween.start()

func set_hp(new_value):
	hp = new_value
	
	if is_network_master():
		rset("puppet_hp", hp)

func puppet_hp_set(new_value):
	puppet_hp = new_value
	
	if not is_network_master():
		hp = puppet_hp

func username_set(new_value) -> void:
	username = new_value
	
	if is_network_master() and username_text_instance != null:
		username_text_instance.text = username
		rset("puppet_username", username)

func puppet_username_set(new_value) -> void:
	puppet_username = new_value
	
	if not is_network_master() and username_text_instance != null:
		username_text_instance.text = puppet_username

func _network_peer_connected(id) -> void:
	rset_id(id, "puppet_username", username)
	

func _on_NetworkTickRate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_rotation", rotation_degrees)

sync func instance_bullet(id):
	var player_bullet_instance = Global.instance_node_at_location(player_bullet, Persistent_Nodes, shoot_point.global_position)
	player_bullet_instance.name = "Bullet" + name + str(Network.networked_object_name_index)
	player_bullet_instance.set_network_master(id)
	player_bullet_instance.player_rotation = $Sprite.rotation
	player_bullet_instance.player_owner = id
	Network.networked_object_name_index += 1


sync func update_position(pos):
	global_position = pos
	puppet_position = pos

func _on_Reload_timer_timeout():
	cooldown = false


func _on_Hitbox_area_entered(area):
	if area.get_parent().name == "AnimatedSprite":
		if area.get_parent() in self.get_children():
			pass
		else:
			rpc("hit_by_damager", 15)
	if get_tree().is_network_server():
		if area.get_parent().name == "AnimatedSprite":
			if area.get_parent() in self.get_children():
				pass
			else:
				rpc("hit_by_damager", 15)
		elif area.is_in_group("Player_damager") and area.get_parent().player_owner != int(name):
			rpc("hit_by_damager", area.get_parent().damage)
			area.get_parent().queue_free()
			
			
sync func hit_by_damager(damage):
	hurt = true
	hp -= damage
#	print(get_parent().get_node("Sprite"))
	if self.name == "1":
		if is_instance_valid(get_parent().get_node("SFX")):
			get_parent().get_node("SFX")._on_Player_HealthUpdate(damage)
	else:
		if is_instance_valid(get_parent().get_node("SFX2")):
			get_parent().get_node("SFX2")._on_Player_HealthUpdate(damage)
#	modulate = Color(5,5,5,1)
#	print(damage)
	
sync func destroy() -> void:
	username_text_instance.visible = false
	visible = false
	$CollisionShape2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true

func _exit_tree() -> void:
	if is_network_master():
		Global.player_master = null
		
remotesync func _anim():
	$AnimatedSprite.play()
	if $AnimatedSprite.animation != "die":
		if atk == true:
			$AnimatedSprite.animation = "atk"
		elif melee == true:
			$AnimatedSprite.animation = "melee"
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
			$AnimatedSprite/Area2D.scale.x = -1
		else:
			$AnimatedSprite/Area2D.scale.x = 1
