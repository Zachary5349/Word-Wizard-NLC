extends Node

var screen_size
onready var lineEdit = get_node("CanvasLayer/Control/LineEdit") # lineedit node 
var template_let_slot = preload("res://WScenes/LetterSlot.tscn") # each letter placeholder in the interface
onready var hbox = get_node("CanvasLayer/Control/MarginContainer/HBoxContainer") # letters holder node 
var hud = false
var spire_list = []
var line_list = []
var orb_list = []
var line_count = 0
signal hud(visibility, words)
var rand_num = 0
var trail_box = preload("res://WScenes/trail.tscn")
var word_length = 0
var once = false
var stop = false
var process = false

func _ready():
	Master.current = "worm"
	$Shadow.position = Vector2($Player.position.x, $Player.position.y+12)
	$Player.move = false
	#allow randomization and get a randum number from 0-1
	randomize()
	rand_num = randf()
#	_hide()
	#getting the screen size
	screen_size = get_viewport().size
	
	#setting the shadows
	$Shadow.self_modulate.a = .1
	$Shadow/Shadow.self_modulate.a = .15
	
	#stopping input process
	$CanvasLayer/Control.process = false
	
	#create 3 spires
	spire()
	spire()
	spire()
	
	#setting the starting position of the player, boss, and screen warning
#	$Player.position.x = screen_size.x / 2
#	$Player.position.y = screen_size.y / 2 + screen_size.y/5
	$Player.speed = 100 #changing the player speed
	$Player.z_index = 3 #changing the z_layer to make it easier for the player to appear behind the rocks
	
#	$Giant_Worm.position.x = screen_size.x / 2
#	$Giant_Worm.position.y = screen_size.y / 2 - screen_size.y/3
	
#	$Screen_Warning.position.x = screen_size.x / 2
#	$Screen_Warning.position.y = screen_size.y / 2 
	$CanvasLayer/Screen_Warning.self_modulate.a = 0 #setting the opacity to 0 so its not visible at the start
	
	#hiding the correct sprite
	$CanvasLayer/Correct.visible = false
	$AnimationPlayer.play("intro")
	yield($AnimationPlayer, "animation_finished")
	$Audio_Timer.start()
	$Player.move = true
	$Giant_Worm.visible = true
	process = true

func _process(delta):
	if $Camera2D.current == true:
		if $Camera2D.zoom.x < 3 && $Camera2D.zoom.y < 3:
			$Camera2D.zoom.x += 0.001
			$Camera2D.zoom.y += 0.001
		$Camera2D.global_position = lerp($Camera2D.global_position, get_node("Giant_Worm").global_position, 1*delta)
		print($Camera2D.global_position)
	else:
		$Camera2D.global_position = $Player.global_position
	if process == true:
		$Giant_Worm.player = $Player.position #setting the boss' player variable to the player's position

		#setting the shadows position to the players position
		$Shadow.position.x = $Player.position.x
		$Shadow.position.y = $Player.position.y+12

		#checking if each spire's word games have been completed, then checing if the timer hasn't ran out
		#if all the spires are complete then it kills the boss, stops the trail, and adds points to the lines
		#sets each of the lines second point to the boss' position - the timer's time left
		#to create a laser moving down the body effect
		line_count = 0
		for each in spire_list:
			if !stop:
				if each.index == 3:
					line_count += 1
				if line_count == 3:
					$Giant_Worm.health -= 1
					$Trail_Timer.stop()
					for line in line_list:
						if line.get_point_count() < 2:
							line.add_point($Giant_Worm.position)
						else:
							line.set_point_position(1, Vector2($Giant_Worm.position.x, $Giant_Worm.position.y - $beam_timer.time_left*100))
							if !once:
								$beam_timer.start()
								$Camera2D.current = true
								
								once = true
							if $beam_timer.time_left == 0:
								stop = true
								#once time is out it removes everything
								for beams in line_list:
									remove_child(beams)
								line_list = []

		#checks if the dist between boss and player is just above the attack range to stop the trail
		if sqrt(($Giant_Worm.player.x-$Giant_Worm.position.x)*($Giant_Worm.player.x-$Giant_Worm.position.x) + ($Giant_Worm.player.y-$Giant_Worm.position.y)*($Giant_Worm.player.y-$Giant_Worm.position.y)) <= 50.01:
			$Trail_Timer.stop()

		#once the boss finishes attacking it resumes the trail
		if $Giant_Worm.attack_phase == 3:
			$Trail_Timer.start()

		#detects left click
#		if Input.is_action_pressed("left_click"):
#			$Player.atk = true

		#manages visibility layers on the spires
		for each in spire_list:
			if each.position.y > $Player.position.y:
				each.z_index = 4
			else:
				each.z_index = 2

		#changing the opacity of the screen warning based on the time left before the boss' attack in order
		#to create a fade in effect
		if $Giant_Worm/AttackTimer.time_left > 0:
			$CanvasLayer/Screen_Warning.self_modulate.a = -$Giant_Worm/AttackTimer.time_left/1.3 + .7
		elif $CanvasLayer/Screen_Warning.self_modulate.a > 0:
			$CanvasLayer/Screen_Warning.self_modulate.a -= .01
		else:
			$CanvasLayer/Screen_Warning.self_modulate.a = 0
		
#func _hide(): # hide the letter input interface
#	$Control.visible = false 
#	for x in lineEdit.max_length+2:
#		queue_free()
#	$Control.process = false # stop processing input
#	$LineEdit.clear() # clear input

#creates a spire and increases the random number 1/3
func spire():
	var spire = load("res://WScenes/Word_Spire.tscn")
	var new_spire = spire.instance()
	
	var spire_spawn_loc = $Spire_Spawn/Spawn_Path
	spire_spawn_loc.unit_offset = rand_num
	
	rand_num += .333333
	if rand_num > 1:
		rand_num -= 1
	
	new_spire.position = spire_spawn_loc.position
	new_spire.z_index = -9;
	
	#creates a new line above the spire and adds the spire to the spire list
	line(new_spire.position)
	
	add_child(new_spire, true)
	spire_list.append(new_spire)

#creates a new line and orb and adds the orb and line to corresponding lists
func line(pos):
	var line = load("res://WScenes/Line2D.tscn")
	var new_line = line.instance()
	var orb = load("res://WScenes/Circle.tscn")
	var new_orb = orb.instance()
	
	new_orb.position = Vector2(pos.x, pos.y - 85)
	new_line.add_point(Vector2(pos.x, pos.y - 85))
	
	add_child(new_line, true)
	add_child(new_orb, true)
	line_list.append(new_line)
	orb_list.append(new_orb)

#when the scene is entered, checks if a trail is created, if it is then it starts the trail animation
func _on_Battle_Scene_child_entered_tree(node):
	if node.name.substr(0,5) == "trail":
		node.frame = 0
		node.global_position = $Giant_Worm.global_position
		node.look_at($Player.global_position)
		yield(get_tree().create_timer(2.28), "timeout")
		#ends once timer runs out
		node.queue_free()

#once the trail timer runs out it creates a new trail
func _on_Trail_Timer_timeout():
	var dirt = trail_box.instance()
	dirt.name = "trail"
	add_child(dirt, true)

#when a new word is received, it chekcs if the word is correct
func _on_Control_word(word):
	var index = 0
	for each in spire_list:
		if each.can_use and word == each.words[each.index]:
			each.index += 1
			if each.index > 2:
				emit_signal("hud", false, each.scrambled_list)
				Engine.time_scale = 1
				$Player.move = true
				orb_list[index].state += 1
			else:
				$CanvasLayer/Correct.visible = true
			$CanvasLayer/Control._hide()
			$CanvasLayer/Control.process = false 
		index += 1

#when any key is pressed this activates
func _input(event: InputEvent):
	for each in spire_list: #for each spire it detects the enter and esc key
		if Input.is_action_just_pressed("enter"):
			if each.can_use: #opens the hud/input
				emit_signal("hud", true, each.scrambled_list)
				Engine.time_scale = 0.1
				$CanvasLayer/Control._show(each.scrambled_list[each.index].length())
				$CanvasLayer/Control.process = true
				$Player.move = false
				$CanvasLayer/Correct.visible = false
#				$CanvasLayer/Control/LineEdit.max_length = 4 #make sure player can't type more than distance
		
		if Input.is_action_pressed("tab"): #closes the hud/input
			emit_signal("hud", false, each.scrambled_list)
			Engine.time_scale = 1
			$CanvasLayer/Control._hide()
			$CanvasLayer/Control.process = false
			$Player.move = true

#once the beam timer stops it kills the boss
func _on_beam_timer_timeout():
	$Giant_Worm/YSort/AnimatedSprite.play("dead")
	yield($Giant_Worm/YSort/AnimatedSprite, "animation_finished")
	$AnimationPlayer.play("end")
	yield($AnimationPlayer, "animation_finished")
	if Master.mode == "story":
		get_tree().change_scene("res://Scenes/end worm.tscn")
	elif Master.mode == "select":
		get_tree().change_scene("res://Scenes/LevelSelect.tscn")

func _on_Audio_Timer_timeout():
	$rumble_noise.play(5.5)
