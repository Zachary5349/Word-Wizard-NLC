extends Node2D

var Enemy = preload("res://ABCscenes/EnemyPath.tscn")
var bullet_scene = preload("res://ABCscenes/bullet.tscn")
var Wizard = preload("res://ABCscenes/Wizard.tscn")

onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var spawn_timer = $SpawnTimer
onready var difficulty_timer = $DifficultyTimer
onready var health_bar = $CanvasLayer/SFX
onready var difficulty_bar = $CanvasLayer/DifficultyBar
onready var countdown_timer = $CanvasLayer/Countdown/CountdownTimer
onready var killed_value = $CanvasLayer/KilledChange
onready var killed_value2 = $CanvasLayer/KilledChange2
onready var health_value = $CanvasLayer/HealthChange 
onready var Water_Blast = preload("res://ABCscenes/water.tscn")
var lastPath = 0

onready var game_over_screen = $CanvasLayer/GameOverScreen
var transition = 0
var active_enemy = null
var current_letter_index: int = -1

var difficulty: int = 0
var enemies_killed: int = 0
export var transition_variable = 0

var seconds = 0
var stagetimer = 1

var enemies = []
var valid_enemies = []
var current_enemies = []
func _ready() -> void:
	Master.current = "dragon"
	$AudioStreamPlayer.play()
	Master.current = "dragon"
	$Player2.move = false
	$CanvasLayer/Animation1.play("intro")
	health_bar.hide()
	difficulty_bar.hide()
	game_over_screen.hide()
	$CanvasLayer/Countdown/seconds.visible = false
	$CanvasLayer/BlackBorder.visible = false
	$CanvasLayer/Animation2Button2.visible = false
	$Cutscene/Animation2Text1.visible = false
	$Dragon.visible = true
	$Dragon2.visible = false
	$border.visible = false
	$ending.visible = false
	$Cutscene/Dragon2.visible = false
	$CanvasLayer/Health.visible = false
	$CanvasLayer/HealthConstant.visible = false
	$CanvasLayer/HealthChange.visible = false
	$CanvasLayer/EneminesKilled.visible = false
	$CanvasLayer/Constant.visible = false
	$CanvasLayer/KilledChange.visible = false
	$CanvasLayer/Constant2.visible = false
	$CanvasLayer/KilledChange2.visible = false
	$CanvasLayer/EneminesKilled.visible = false
#	$Leaderboard.mouse_filter = Control.MOUSE_FILTER_STOP


func find_new_active_enemy(typed_character: String):
	for enemy in valid_enemies:
		if valid_enemies.size() > 0:
				var prompt = enemy.get_child(0).get_child(0).get_prompt()
				var next_character = prompt.substr(0, 1)
				if next_character == typed_character:
	#				print("found new enemy that starts with %s" % next_character)
					active_enemy = enemy
					current_letter_index = 1
					active_enemy.get_child(0).get_child(0).set_next_character(current_letter_index)
					current_enemies.append(active_enemy)
					return


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()

		if active_enemy == null:
			find_new_active_enemy(key_typed)
		else:
			var prompt = active_enemy.get_child(0).get_child(0).get_prompt()
			var next_character = prompt.substr(current_letter_index, 1)
			if key_typed == next_character:
#				print("successfully typed %s" % key_typed)
				current_letter_index += 1
				active_enemy.get_child(0).get_child(0).set_next_character(current_letter_index)
				if current_letter_index == prompt.length():
					$Player2.atk = true
					yield(get_tree().create_timer(0.3), "timeout") # wait for the middle of spell
					current_letter_index = -1
					var water = Water_Blast.instance()
					active_enemy.get_parent().add_child(water)
					valid_enemies.remove(valid_enemies.find(active_enemy))
#					active_enemy.queue_free()
					active_enemy = null
					enemies_killed += 1
					if transition == 0:
						killed_value.text = str(enemies_killed)
					else:
						killed_value2.text = str(enemies_killed)
						
					if transition == 0:
						if enemies_killed >= 15:
							$CanvasLayer/Animation1.play("intro2")
							health_bar.hide()
							difficulty_bar.hide()
							spawn_timer.stop()
							difficulty_timer.stop()
							active_enemy = null
							for enemy in $path1.get_children():
								enemy.queue_free()
							for enemy in $path2.get_children():
								enemy.queue_free()
							for enemy in $path3.get_children():
								enemy.queue_free()
							for enemy in $path4.get_children():
								enemy.queue_free()
							for enemy in $path5.get_children():
								enemy.queue_free()
#							for enemy in valid_enemies:
#								enemy.queue_free()
							enemies.clear()
							valid_enemies.clear()
							
							
							current_letter_index = -1
							$CanvasLayer/Countdown/seconds.visible = false
							$CanvasLayer/Health.visible = false
							$CanvasLayer/HealthConstant.visible = false
							$CanvasLayer/HealthChange.visible = false
							$CanvasLayer/EneminesKilled.visible = false
							$CanvasLayer/Constant.visible = false
							$CanvasLayer/Constant2.visible = false
							$CanvasLayer/KilledChange2.visible = false
							$ending.visible = false
							$CanvasLayer/KilledChange.visible = false
							
							
							transition = 1
							
					else:
						if  enemies_killed >= 7:
							$CanvasLayer/Animation1.play("end")
							if Master.mode == "story":
								get_tree().change_scene("res://Scenes/end fire.tscn")
							elif Master.mode == "select":
								get_tree().change_scene("res://Scenes/LevelSelect.tscn")
							$ending.visible = true
							health_bar.hide()
							difficulty_bar.hide()
							spawn_timer.stop()
							difficulty_timer.stop()
							active_enemy = null
							current_letter_index = -1
							$CanvasLayer/Countdown/seconds.visible = false 
							$CanvasLayer/Health.visible = false
							$CanvasLayer/HealthConstant.visible = false
							$CanvasLayer/HealthChange.visible = false
							$CanvasLayer/EneminesKilled.visible = false
							$CanvasLayer/Constant.visible = false
							$CanvasLayer/Constant2.visible = false
							$CanvasLayer/KilledChange2.visible = false
							$CanvasLayer/KilledChange.visible = false
							
			else:
#				print("incorrectly typed %s instead of %s" % [key_typed, next_character])
				pass

func _on_SpawnTimer_timeout() -> void:
	spawn_enemy()
	
	
#func aim_fire():
	#var bullet = bullet_scene.instance()
	#bullet.global_position = $Position2Di2.global_position
	#bullet.direction = ($Position2D2.global_position - global_position).normalized()
	#bullet.rotation_degrees = rotation_degrees
	#get_tree().get_root().add_child(bullet)
	
	

func spawn_enemy():
	var enemy_instance = Enemy.instance()
#	if promptTrans == 0:
#		enemy_instance.get_child(0).get_child(0).prompttransition = 0
#	else:
#		enemy_instance.get_child(0).get_child(0).prompttransition = 1
#
	var pathNum = (randi() % 4) + 1
	if pathNum == lastPath:
		if pathNum == 5:
			pathNum -= 1
		else:
			pathNum += 1
#	enemy_instance.global_position = spawns[index].global_position
	enemy_instance.get_child(0).get_child(0).prompttransition = transition
	get_node("path" + str(pathNum)).add_child(enemy_instance)
	lastPath = pathNum
#	enemies.append(get_node("path" + str(pathNum)).get_child(get_child_count()-1))
#
#	enemies.append(get_node("path" + str(pathNum)).get_child(get_child_count))
#	print("spawned")
#	print($path1.get_children() + $path2.get_children() + $path3.get_children() + $path4.get_children() + $path5.get_children())
	enemy_instance.get_child(0).get_child(0).set_difficulty(difficulty)
	
	

func playerHit():
	$Player2._damage(15)
	active_enemy = null
	for enemy in $path1.get_children():
		enemy.queue_free()
	for enemy in $path2.get_children():
		enemy.queue_free()
	for enemy in $path3.get_children():
		enemy.queue_free()
	for enemy in $path4.get_children():
		enemy.queue_free()
	for enemy in $path5.get_children():
		enemy.queue_free()
#	for enemy in valid_enemies:
#		if enemy.get_class() == "PathFollow2D":
#			enemy.queue_free()
	enemies.clear()
	valid_enemies.clear()
	current_letter_index = -1
	if health_bar.value<= 0:
		game_over()


func game_over():
	game_over_screen.show()
	spawn_timer.stop()
	difficulty_timer.stop()
	active_enemy = null
	for enemy in $path1.get_children():
		enemy.queue_free()
	for enemy in $path2.get_children():
		enemy.queue_free()
	for enemy in $path3.get_children():
		enemy.queue_free()
	for enemy in $path4.get_children():
		enemy.queue_free()
	for enemy in $path5.get_children():
		enemy.queue_free()
#	for enemy in valid_enemies:
#		enemy.queue_free()
	enemies.clear()
	valid_enemies.clear()	
	current_letter_index = -1
	
		
		
func start_game():
	active_enemy = null
	for enemy in $path1.get_children():
		enemy.queue_free()
	for enemy in $path2.get_children():
		enemy.queue_free()
	for enemy in $path3.get_children():
		enemy.queue_free()
	for enemy in $path4.get_children():
		enemy.queue_free()
	for enemy in $path5.get_children():
		enemy.queue_free()
#	for enemy in valid_enemies:
#		enemy.queue_free()
	enemies.clear()
	valid_enemies.clear()
	
	current_letter_index = -1
	game_over_screen.hide()
	difficulty = 0
	enemies_killed = 0
	randomize()
	difficulty_timer.start()
	spawn_enemy()
	#set_enemy_texture()
	spawn_timer.start()
	difficulty_bar.value = 30
	health_bar.value = 70
	difficulty_timer.start()
	$background2.visible = true
	$background1.visible = false
#	$CanvasLayer/Health.visible = true
#	$CanvasLayer/HealthConstant.visible = true
#	$CanvasLayer/HealthChange.visible = true
	$CanvasLayer/EneminesKilled.visible = true
	$CanvasLayer/Constant.visible = true
	$CanvasLayer/KilledChange.visible = true
	
	
func start_game2():
	
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer2.play()
	active_enemy = null
	for enemy in $path1.get_children():
		enemy.queue_free()
	for enemy in $path2.get_children():
		enemy.queue_free()
	for enemy in $path3.get_children():
		enemy.queue_free()
	for enemy in $path4.get_children():
		enemy.queue_free()
	for enemy in $path5.get_children():
		enemy.queue_free()
#	for enemy in valid_enemies:
#		enemy.queue_free()
	enemies.clear()
	valid_enemies.clear()
	
	
	current_letter_index = -1
	game_over_screen.hide()
	difficulty = 0
	enemies_killed = 0
	randomize()
	difficulty_timer.start()
	spawn_enemy()
	#set_enemy_texture()
	spawn_timer.start()
	difficulty_bar.value = 30
	difficulty_timer.start()
	difficulty_timer.wait_time = 10
	seconds = 10
	spawn_timer.wait_time = 6

func _on_RestartButton_pressed() -> void:
	start_game()


	pass # Replace with function body.




func _on_Difficultytimer_timeout():
	if stagetimer == 1:
		if difficulty < 7:
			difficulty += 1
			difficulty_timer.wait_time = 10
		
			difficulty_timer.start()
			GlobalSignals.emit_signal("difficulty_increased", difficulty)
#			print("Difficulty increased to %d" % difficulty)
			var new_wait_time = spawn_timer.wait_time - 1
			spawn_timer.wait_time = clamp(new_wait_time, 1, spawn_timer.wait_time)
		
		
			difficulty_bar.value = difficulty_bar.value + 10
	else:
		if difficulty < 7:
			difficulty += 1
			difficulty_timer.wait_time = 10
			
			difficulty_timer.start()
			GlobalSignals.emit_signal("difficulty_increased", difficulty)
		
#			print("Hard Difficulty increased to %d" % difficulty)
			var new_wait_time = spawn_timer.wait_time - 1
			spawn_timer.wait_time = clamp(new_wait_time, 1, spawn_timer.wait_time)
		
			difficulty_bar.value = difficulty_bar.value + 10
		elif difficulty == 7:
			difficulty += 1
			difficulty_timer.wait_time = 10
			spawn_timer.wait_time = 5
			difficulty_timer.start()
			GlobalSignals.emit_signal("difficulty_increased", difficulty)
#			print("Hard Final difficulty is  %d" % difficulty)
			var new_wait_time = spawn_timer.wait_time - 1
			spawn_timer.wait_time = clamp(new_wait_time, 1, spawn_timer.wait_time)

#var repeat = 0

func _physics_process(delta):
		$Player.position = Vector2(600,178)
	#if repeat < 7:
		if seconds < 10.1:
			seconds -=0.0166
			$CanvasLayer/Countdown/seconds.set_text(str(seconds))
		if seconds < 0.05:
			$CanvasLayer/Countdown/CountdownTimer.stop()
			#repeat +=1
			seconds = 10
		else:
			null
		
		


func _on_Animation2Button2_pressed():
	 transition_variable = 1
	 health_bar.show()
	 difficulty_bar.show()
	 $CanvasLayer/Countdown/CountdownTimer.start()
	 $CanvasLayer/Countdown/seconds.visible = true     
	 seconds = 10  
	 difficulty_bar.value = 30
	 difficulty = 0
	 randomize()
	 difficulty_timer.start()
	 spawn_timer.start()
	 difficulty_timer.start()
	 difficulty_timer.wait_time = 10
	 seconds = 10
	 spawn_timer.wait_time = 7
	 $Cutscene/Animation2Text1.visible = false
	 $Cutscene/Animation2Border.visible = false
	 $CanvasLayer/Animation2Button2.visible = false
	 $background2.visible = false
	 $background1.visible = true
	 $Cutscene/Dragon1.visible = false
	 $Cutscene/Animation1BG.visible = false
	 $Dragon.visible = false
	 $Dragon2.visible = true
	 $border.visible = true
	 $Cutscene/Dragon2.visible = false
	 $background2.visible = false
	 $background1.visible = true
	 $CanvasLayer/Health.visible = true
	 $CanvasLayer/HealthConstant.visible = true
	 $CanvasLayer/HealthChange.visible = true
	 $CanvasLayer/EneminesKilled.visible = true
	 $CanvasLayer/Constant.visible = false
	 $CanvasLayer/KilledChange.visible = false
	 $CanvasLayer/Constant2.visible = true
	 $CanvasLayer/KilledChange2.visible = true
	 $CanvasLayer/EneminesKilled.visible = true
	 enemies_killed = 0
	 


func _on_path1_child_entered_tree(node):
	if node.get_class() == "PathFollow2D" && node.get_child(0).get_child(0).get_class() == "KinematicBody2D":
		enemies.append(node)
		valid_enemies.append(node)


func _on_path2_child_entered_tree(node):
	if node.get_class() == "PathFollow2D" && node.get_child(0).get_child(0).get_class() == "KinematicBody2D":
		enemies.append(node)
		valid_enemies.append(node)


func _on_path3_child_entered_tree(node):
	if node.get_class() == "PathFollow2D" && node.get_child(0).get_child(0).get_class() == "KinematicBody2D":
		enemies.append(node)
		valid_enemies.append(node)


func _on_path4_child_entered_tree(node):
	if node.get_class() == "PathFollow2D" && node.get_child(0).get_child(0).get_class() == "KinematicBody2D":
		enemies.append(node)
		valid_enemies.append(node)


func _on_path5_child_entered_tree(node):
	if node.get_class() == "PathFollow2D" && node.get_child(0).get_child(0).get_class() == "KinematicBody2D":
		enemies.append(node)
		valid_enemies.append(node)




func _on_Animation1Button_pressed():
	 print("popaosd")
	 start_game()
	 health_bar.show()
	 difficulty_bar.show()
	 $CanvasLayer/Countdown/CountdownTimer.start()
	 $CanvasLayer/Countdown/seconds.visible = true     
	 seconds = 10  
	 difficulty_bar.value = 30
	 $Cutscene/Animation1BG.visible = false
	 $Cutscene/Animation1Text1.visible = false
	 $Cutscene/Animation1Text2.visible = false
	 $Cutscene/Animation1Text3.visible = false
	 $Cutscene/Animation1Text4.visible = false
	 $Cutscene/Dragon1.visible = false
	 
	 $CanvasLayer/Animation1Button.visible = false
	 $background2.visible = true
	 $background1.visible = false


func _on_Play_pressed():
	 start_game()
	 health_bar.show()
	 difficulty_bar.show()
	 $CanvasLayer/Countdown/CountdownTimer.start()
	 $CanvasLayer/Countdown/seconds.visible = true     
	 seconds = 10  
	 difficulty_bar.value = 30
	 $Cutscene/Animation1BG.visible = false
	 $Cutscene/Animation1Text1.visible = false
	 $Cutscene/Animation1Text2.visible = false
	 $Cutscene/Animation1Text3.visible = false
	 $Cutscene/Animation1Text4.visible = false
	 $Cutscene/Dragon1.visible = false
	 
	 $CanvasLayer/Animation1Button.visible = false
	 $background2.visible = true
	 $background1.visible = false

