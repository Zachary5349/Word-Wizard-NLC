extends Node2D

var cut_scene = 0 # tracks which cutscene we're on
var continue_scn = true # tracks if can contiue cut scene
var in_cut_scene = false # checks if still in cutscene/intro
var last_tile = Vector2(0,6) # tracks last tile player built to; builds bridge from this point
var tile = Vector2() # player's selected tile
var plank_tile = Vector2() # player's selected plank tile
var player_tile = Vector2() # tile the player is standing on
var player_tile_id = 0 # id of tile the player is standing on
var player_pos = Vector2() # tracks player position

var x_dist = 0
var y_dist = 0
var dist = 0 

var log_lock = false # locks the selected log; player can't click on a different log

var timer_count = 0 # counter for sinking tiles

var template_let_slot = preload("res://Scenes/LetterSlot.tscn") # each letter placeholder in the interface

var grass_spawn_sprite = preload("res://Scenes/GrassSpawn.tscn") # grass spawning animation

var slow_scale = 1 # scale of which the world slows down
# loading tile resources to modify fps(slow and speed)
var water1 = preload("res://Assets/water1.tres")
var water2 = preload("res://Assets/water2.tres")
var log1 = preload("res://Assets/log.tres")
var log2 = preload("res://Assets/log_flash.tres")
var magic = preload("res://Assets/grass_spawn.tres")
var hmagic = preload("res://Assets/grass_spawn2.tres")
var grass1 = preload("res://Assets/grass.tres")
var grass2 = preload("res://Assets/grass2.tres")
var grass3 = preload("res://Assets/sinking_grass.tres")
var grass4 = preload("res://Assets/sinking_grass2.tres") 

#node variables (for possible future reparenting)
onready var hbox = get_node("CanvasLayer/Control/MarginContainer/HBoxContainer") # letters holder node 
onready var lineEdit = get_node("CanvasLayer/Control/LineEdit") # lineedit node 
onready var player = get_node("Player") # player node
onready var TileMap1 = get_node("TileMap") # background tilemap node
onready var TileMap2 = get_node("TileMap2") # flashing tiles node
onready var Control1 = get_node("CanvasLayer/Control") # input node/scene

var bridges_drawn = 0 # tracks # of bridges drawn
var bridge_tiles = [] # tracks the coordinates of the last placed bridge tiles (for sinking bridges)
var bridges_spawn = [] # tracks last bridge spawned
var last_grass_placed = Vector2.ZERO # coordinates of latest bridge tile placed


func _ready():
	$CanvasLayer/Control.visible = false
	$CanvasLayer/SFX.visible = false
	$CanvasLayer/Label3.percent_visible = 0
	$CanvasLayer/ColorRect.color = Color(0,0,0)
	set_process(false) # stop process until cutscenes over
	yield(get_tree().create_timer(0.5), "timeout")
	$CanvasLayer/AnimationPlayer.play("beg")
	$Player.move = false
	yield($CanvasLayer/AnimationPlayer, "animation_finished")
	in_cut_scene = true


func _process(_delta):
	if $CanvasLayer/SFX.died == true:
		yield(get_tree().create_timer(1), "timeout")
		$CanvasLayer/SFX.died = false
		get_tree().change_scene("res://Scenes/Title Screen.tscn")
		$CanvasLayer/AnimationPlayer.play("RESET")
		$Kraken.follow = false
#	if $Kraken.follow != true:
#		$Kraken.global_position.x = lerp($Kraken.global_position.x, 341, 0.1)  # make Kraken follow player, lerp position to slow down
	
	# offset tracked player position to more accurately find tilemap coords
	player_pos = Vector2(player.global_position.x, player.global_position.y+5) 
	player_tile = TileMap1.world_to_map(player_pos)
	player_tile_id = TileMap1.get_cell(player_tile.x, player_tile.y)
	
	if player_tile_id == 0 || player_tile_id == 1: # if the player gets sunk into water, move the player onto a solid platform and take damage
		
		 # checks each tile around player for a solid tile (log or grass)
		if TileMap1.get_cell(player_tile.x+1, player_tile.y) == 2 || 3 || 4:
			# if there is a solid tile, set the player's tile position there
			player_tile.x += 1 
		elif TileMap1.get_cell(player_tile.x+1, player_tile.y+1) == 2 || 3 || 4:
			player_tile.x+=1
			player_tile.y+=1
		elif TileMap1.get_cell(player_tile.x+1, player_tile.y-1) == 2 || 3 || 4:
			player_tile.x+=1
			player_tile.y-=1
		elif TileMap1.get_cell(player_tile.x, player_tile.y+1) == 2 || 3 || 4:
			player_tile.y+=1
		elif TileMap1.get_cell(player_tile.x, player_tile.y-1) == 2 || 3 || 4:
			player_tile.y-=1
		elif TileMap1.get_cell(player_tile.x-1, player_tile.y) == 2 || 3 || 4:
			player_tile.x-=1
		elif TileMap1.get_cell(player_tile.x-1, player_tile.y+1) == 2 || 3 || 4:
			player_tile.x-=1
			player_tile.y+=1
		elif TileMap1.get_cell(player_tile.x-1, player_tile.y-1) == 2 || 3 || 4:
			player_tile.x-=1
			player_tile.y-=1
		player._damage(15) # deal 15 damage to the player for touching water
		$touchWater.play()
		player.global_position = TileMap1.map_to_world(player_tile) # move the player to the solid tile
		
	if player_tile_id == 2: # whenever player stands on a log
		last_tile = player_tile # set that log to the tile to bridge from
		# setting the player to bridge from where ever they're standing is not a good idea
		# because it can add unncessary distance for the player if they are not standing on the edge
	elif player_tile_id == 5 || player_tile_id == 6: # if player is standing on a sinking tile
		# make the player slowly sink as well
		player.velocity.y += 0.1
		player.velocity = player.velocity.normalized()
		player.velocity = player.move_and_slide(player.velocity/10 * player.speed)


func _input(event: InputEvent): # click/esc handler function
	if event.is_action_pressed("click"):
		if in_cut_scene && continue_scn == true: # if we're still inside the intro cutscene
			$click.stop()
			$click.play()
			continue_scn = false
			if cut_scene == 0: # if it is the first cutscene
				Engine.time_scale = 1
				$CanvasLayer/BlackBar1.visible = true
				$CanvasLayer/BlackBar2.visible = true
				$ColorRect.visible = true
				$CanvasLayer/AnimationPlayer.play("intro") # play first cutscene anim
				$CanvasLayer/Label.text = "And your energy wand is across the water!"
			elif cut_scene == 1:
				$CanvasLayer/AnimationPlayer.play("back")
				yield(get_tree().create_timer(0.5), "timeout") # wait for anim to end
				$CanvasLayer/Label.text = "Click on the planks from your boat to get across!"
				# slow down
				
				log2.fps = 2
				water1.fps = 4
				water2.fps = 4
				log1.fps = 3
				log2.fps = 3
				grass1.fps = 2
				grass2.fps = 2
				grass3.fps = 4
				log2.set_current_frame(0)
				$log_flash.visible = true # highlight logs
			elif cut_scene == 2:
				$CanvasLayer/AnimationPlayer.play("bridge_text")
				$CanvasLayer/Label.text = "Use the earth wand to bridge between the planks!"
				$log_flash.visible = false
				if $magic.visible != true: # if magic isn't already show, start on the first frame of the tiled resource
					hmagic.set_current_frame(0)
				$magic.visible = true
				yield(get_tree().create_timer(1.25), "timeout") # wait for magic anim to end
				$magic.visible = false
				$grass.visible = true
			elif cut_scene == 3:
				$CanvasLayer/AnimationPlayer.play("dist")
				$CanvasLayer/Label.text = "Make a bridge by typing a word with the same length as the distance between the planks!"
				$grass.visible = false
				if $sink.visible != true:
					grass3.set_current_frame(0)
				$sink.visible = true
				yield(get_tree().create_timer(1), "timeout")
				$sink.visible = false
				# normal time
				log2.fps = 6
				water1.fps = 8
				water2.fps = 8
				log1.fps = 6 
				grass1.fps = 4
				grass2.fps = 4
				grass3.fps = 4
				grass4.fps = 4
			elif cut_scene == 4:
				$CanvasLayer/Label2.visible = false
				$CanvasLayer/Label.text = "Avoid sinking and the Kraken's water blasts! Good luck!"
				$CanvasLayer/Label2.text = "Click to start"
				$CanvasLayer/AnimationPlayer.play("gl")
			elif cut_scene == 5:
				$AudioStreamPlayer.volume_db = -20
				$CanvasLayer/AnimationPlayer.play("start")
				$CanvasLayer/SFX.visible = true
				set_process(true)
				$Player.move = true
				$CanvasLayer/Label.visible = false
				$CanvasLayer/Label2.visible = false
				$CanvasLayer/SFX.visible = true
				in_cut_scene = false # exit cutscene
			yield(get_node("CanvasLayer/AnimationPlayer"), "animation_finished")
			continue_scn = true
#			$CanvasLayer/Control/Label2.visible = true
#			print($CanvasLayer/Label2.text)
#			print($CanvasLayer/Control/Label2.visible)
			
			cut_scene += 1 # next cutscene
		if cut_scene > 5:
			
			$Player/Camera2D.current = true
			tile = TileMap1.world_to_map(get_global_mouse_position()) # finds tilemap coordinates of mouse
			
			if tile != last_tile && TileMap1.get_cell(tile.x, tile.y) == 2 && log_lock == false: # checks if tile is a valid tile to bridge to
				$click.stop()
				$click.play()
				plank_tile = tile # holds selected tile
				# highlight tile
				TileMap1.set_cell(plank_tile.x, plank_tile.y, 7)
				TileMap2.set_cell(last_tile.x, last_tile.y, 7)
				log_lock = true # locks on to the selected plank tile
				player.move = false # player can't move
				
				# calculate the distance between last tile and selected tile
				x_dist = abs(plank_tile.x - last_tile.x)
				y_dist = abs(plank_tile.y - last_tile.y)
				dist = (x_dist + y_dist - 1)
				Control1._show(dist) #initiate letter input interface
				slow_scale = 0.1
				Engine.time_scale = slow_scale # slow down physics and timer time
				water1.fps = 4
				water2.fps = 4
				log1.fps = 3
				log2.fps = 3
				grass1.fps = 2
				grass2.fps = 2
				grass3.fps = 2
				grass4.fps = 2 # slow down speed of tile animations
				

	if event.is_action_pressed("escape"):  # escape interface
		_hide_input()


func _draw_bridge(x1,y1,x2,y2): # draw bridge function
	# calculate distances
	player.atk = true # start spell anim
#	$grassSpawn.play()
	yield(get_tree().create_timer(0.3), "timeout") # wait for the middle of spell
	
	for j in y_dist: # vertical distance
		var sgrass = grass_spawn_sprite.instance() # create new instance for each grass spawn
		var placed = false # if there was a tile placed in this iteration
		if y2-y1 <= 0: # if target y is above base y
			# move up
			if TileMap1.get_cell(x1, y1-j) != 2: # check if tile is water
				last_grass_placed = Vector2(x1, y1-j) # place the tile into var
				placed = true
		else:
			# move down
			if TileMap1.get_cell(x1, y1+j) != 2:
				last_grass_placed = Vector2(x1, y1+j)
				placed = true
		if placed == true:
			bridges_spawn.append(last_grass_placed) # track each bridge tile for spawning
			bridge_tiles.append(last_grass_placed) # track each bridge tile for sinking
			add_child(sgrass, true) # add grass spawn anim sprite
			# place sprite in world in terms of tilemap coords

			yield(get_tree().create_timer(0.1), "timeout") # delay each tile placed
			
	for k in x_dist: # horizontal distance
		var sgrass = grass_spawn_sprite.instance()
		var placed = false
		
		if x2-x1<= 0: # if target x is left to base x
			# move left
			if TileMap1.get_cell(x1-k, y2) != 2:
				placed = true
				last_grass_placed = Vector2(x1-k, y2)
		else:
			# move right
			if TileMap1.get_cell(x1+k, y2) != 2:
				placed = true
				last_grass_placed = Vector2(x1+k, y2)
		if placed == true:
			bridge_tiles.append(last_grass_placed) # track each bridge tile for sinking
			bridges_spawn.append(last_grass_placed)
			add_child(sgrass, true)
			
			yield(get_tree().create_timer(0.1), "timeout") # yields used for time in between grass spawns


func _hide_input(): # hide the letter input interface
	Control1._hide()
	slow_scale = 1
	TileMap1.set_cell(plank_tile.x, plank_tile.y, 2)
	TileMap2.set_cell(last_tile.x, last_tile.y, -1)
	
	Engine.time_scale = 1
	water1.fps = 8
	water2.fps = 8
	log1.fps = 6
	log2.fps = 6
	grass1.fps = 4
	grass2.fps = 4
	grass3.fps = 4
	grass4.fps = 4 #go back to normal time
	log_lock = false
	player.move = true # unlock and player can move
	lineEdit.clear() # clear input


func _on_Control_word_found(): # if the entered word is valid
	_hide_input()
	_draw_bridge(last_tile.x, last_tile.y, plank_tile.x, plank_tile.y) # draws bridge from last tile to selected plank tile
	if bridges_drawn >=2 && bridge_tiles.size() < 1: # if there are no bridges and tiles will sink,
		bridges_drawn = 0 # tiles will not sink for a second
		yield(get_tree().create_timer(1), "timeout") # gives player time to get on the bridge before it sinks
		bridges_drawn = 1
	bridges_drawn += 1 # bridges will now start sinking again because var is >= 2
	
	# track current tile
	last_tile.x = plank_tile.x
	last_tile.y = plank_tile.y  

	log_lock = false # lock off


func _on_Timer_timeout(): # sinking the first tiles
	if bridges_drawn >=  2 && bridge_tiles.size() > 0: # if there has been 2 bridges and bridge tiles
			TileMap1.set_cell(bridge_tiles[0].x,bridge_tiles[0].y, 5)
			grass3.set_current_frame(0)
			timer_count += 1
			yield(get_tree().create_timer(0.5), "timeout")

func _on_Timer2_timeout(): # sinking second tile then resetting first tile
	if bridges_drawn >= 2 && bridge_tiles.size() > 0 && timer_count > 0:  # at least o
		if timer_count % 2 == 0: # even # of sinking tiles exist to sink first one
			if bridge_tiles.size() > 1:
				TileMap1.set_cell(bridge_tiles[1].x,bridge_tiles[1].y, 6)
				grass4.set_current_frame(0)
				timer_count += 1
			TileMap1.set_cell(bridge_tiles[0].x,bridge_tiles[0].y, int(bridge_tiles[0].y)%2)
			bridge_tiles.remove(0) # remove the tile after sinking


func _on_Node2D_child_entered_tree(node): # used for new grass spawn nodes
	if node.get_class() == "AnimatedSprite": # if a new grass is spawned
		var current_spawn = node # tracks current node; without this, using node would track last node that entered because of yield
		current_spawn.frame = 0
		current_spawn.position = TileMap1.map_to_world(last_grass_placed)
#		current_spawn.position.x += 16 # you only need to add 16px if the node is centered, which it's not
#		current_spawn.position.y += 16
		var num = int(current_spawn.name.substr(14,current_spawn.name.length())) # number in animatedsprite's name
		var tile_pos = bridges_spawn[0]
		bridges_spawn.remove(0)
		yield(get_tree().create_timer(0.2), "timeout") # delay being able to stand on tile
		TileMap1.set_cell(tile_pos.x, tile_pos.y, (num%2)+3) # place grass tile
		node.z_index = -1
		yield(get_tree().create_timer(2), "timeout")
		current_spawn.queue_free() # remove grass spawn anim sprites from tree


func _on_Wand_Area_body_entered(body):
	$CanvasLayer/AnimationPlayer.play("end")
	if Master.mode == "story":
		get_tree().change_scene("res://Scenes/end water.tscn")
	elif Master.mode == "select":
		get_tree().change_scene("res://Scenes/LevelSelect.tscn")
