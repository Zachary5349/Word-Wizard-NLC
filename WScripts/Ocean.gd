extends Node2D

var last_tile = Vector2(0,6) # tracks last tile player built to; builds bridge from this point
var tile = Vector2() # player's selected tile
var plank_tile = Vector2() # player's selected plank tile
var player_tile = Vector2() # tile the player is standing on
var player_tile_id = 0 # id of tile the player is standing on
var player_pos = Vector2()

var x_dist = 0
var y_dist = 0
var dist = 0 # dist variables used to calculate distance required for bridges

var log_lock = false # locks the selected log; player can't click on a different log

var slow_scale = 0.1 # scale of which the world slows down
var timer_count = 0 

var template_let_slot = preload("res://Scenes/LetterSlot.tscn") # each letter placeholder in the interface

var water1 = preload("res://Assets/water1.tres")
var water2 = preload("res://Assets/water2.tres")
var log1 = preload("res://Assets/log.tres")
var log2 = preload("res://Assets/log_flash.tres")
var grass1 = preload("res://Assets/grass.tres")
var grass2 = preload("res://Assets/grass2.tres")
var grass3 = preload("res://Assets/sinking_grass.tres")
var grass4 = preload("res://Assets/sinking_grass2.tres") # loading tile resources to modify fps(slow and speed)

onready var hbox = get_node("CanvasLayer/Control/MarginContainer/HBoxContainer") # letters holder node 
onready var lineEdit = get_node("CanvasLayer/Control/LineEdit") # lineedit node 

var bridges_drawn = 0 # tracks # of bridges drawn
var bridge_tiles = [] # tracks the coordinates of the last placed bridge tiles (for sinking bridges)

func _process(delta):
	
	player_pos = Vector2($Player.global_position.x, $Player.global_position.y+5)
	player_tile = $TileMap.world_to_map(player_pos)
	player_tile_id = $TileMap.get_cell(player_tile.x, player_tile.y)
	if player_tile_id == 0 || player_tile_id == 1: # if the player gets sunk into water, move the player onto a sold platform and take damage
		$Player.velocity = Vector2(0.3,0.3)
		if $TileMap.get_cell(player_tile.x+1, player_tile.y) == 2 || 3 || 4: # checks each tile around player for a solid tile (log or grass)
			player_tile.x += 1 # if there is a solid tile, set the player's tile position there
		elif $TileMap.get_cell(player_tile.x+1, player_tile.y+1) == 2 || 3 || 4:
			player_tile.x+=1
			player_tile.y+=1
		elif $TileMap.get_cell(player_tile.x+1, player_tile.y-1) == 2 || 3 || 4:
			player_tile.x+=1
			player_tile.y-=1
		elif $TileMap.get_cell(player_tile.x, player_tile.y+1) == 2 || 3 || 4:
			player_tile.y+=1
		elif $TileMap.get_cell(player_tile.x, player_tile.y-1) == 2 || 3 || 4:
			player_tile.y-=1
		elif $TileMap.get_cell(player_tile.x-1, player_tile.y) == 2 || 3 || 4:
			player_tile.x-=1
		elif $TileMap.get_cell(player_tile.x-1, player_tile.y+1) == 2 || 3 || 4:
			player_tile.x-=1
			player_tile.y+=1
		elif $TileMap.get_cell(player_tile.x-1, player_tile.y-1) == 2 || 3 || 4:
			player_tile.x-=1
			player_tile.y-=1
		$Player.global_position = $TileMap.map_to_world(player_tile) # move the player to the solid tile
		
	if player_tile_id == 2: # whenever player stands on a log
		last_tile = player_tile # set that log to the tile to bridge from
		# setting the player to bridge from where ever they're standing is not a good idea
		# because it can add unncessary distance for the player if they are not standing on the edge
	elif player_tile_id == 5 || player_tile_id == 6:
		$Player.velocity.y += 0.1
		$Player.velocity = $Player.velocity.normalized()
		$Player.velocity = $Player.move_and_slide($Player.velocity/10 * $Player.speed)
		
		
func _input(event: InputEvent): # input handler function
	if event.is_action_pressed("click"):
		
		tile = $TileMap.world_to_map(get_global_mouse_position()) # finds tilemap coordinates of mouse
		
		if tile != last_tile && $TileMap.get_cell(tile.x, tile.y) == 2 && log_lock == false:
		# checks if tile is a valid tile to bridge to
			plank_tile = tile
			$TileMap.set_cell(plank_tile.x, plank_tile.y, 7)
			$TileMap2.set_cell(last_tile.x, last_tile.y, 7)
			yield(get_tree().create_timer(0.5), "timeout") # delay each tile placed
			
			log_lock = true # locks on to the selected plank tile
			$Player.move = false # player can't move
			x_dist = abs(plank_tile.x - last_tile.x)
			y_dist = abs(plank_tile.y - last_tile.y)
			dist = (x_dist + y_dist - 1) # calculate the distance between last tile and selected tile
			
			
			$CanvasLayer/Control.visible = true #initiate letter input interface
			Engine.time_scale = slow_scale # slow down physics and timer time
			water1.fps = 4
			water2.fps = 4
			log1.fps = 3
			log2.fps = 3
			grass1.fps = 2
			grass2.fps = 2
			grass3.fps = 2
			grass4.fps = 2 # slow down speed of tile animations
			lineEdit.grab_focus() # player can start typing
			lineEdit.max_length = dist # make sure player can't type more than distance
			
			print(dist)
			for x in lineEdit.max_length+2:
				var size = 0
				
				var blank_slot_new = template_let_slot.instance() # load letter slot into var
				
				if lineEdit.max_length <= 5: # formatting methods
					blank_slot_new.rect_min_size.x = 95
					blank_slot_new.rect_min_size.y = 95 # max width of letters is 95x95
					
				else: 
				# else the distance is longer than 5, we calculate the width of each letter to fit on the screen
				# this allows for any length of words to fit on the screen
					size = (672/(lineEdit.max_length)
					-(150/lineEdit.max_length))
					blank_slot_new.rect_min_size.x = size
					blank_slot_new.rect_min_size.y = size #adjust the letter slot sizes
					
				if x == 0: # start and end letter slots with left and right margins
					var icon_texture = load("res://Assets/letters/left.png")
					blank_slot_new.get_node("Icon").set_texture(icon_texture)
					
				elif x == (lineEdit.max_length+1):
					var icon_texture = load("res://Assets/letters/right.png")
					blank_slot_new.get_node("Icon").set_texture(icon_texture)
				else:
					# reset each letter to blank slot to match input
					var icon_texture = load("res://Assets/letters/blank.png")
					blank_slot_new.get_node("Icon").set_texture(icon_texture)
				hbox.add_child(blank_slot_new, true)
			$CanvasLayer/Control.process = true
			get_node("CanvasLayer/Control/MarginContainer/HBoxContainer/Let"+ str(lineEdit.caret_position+2)+"/selectf").visible = true
	
	if event.is_action_pressed("escape"):  # escape interface
		_hide()


func draw_bridge(x1,y1,x2,y2): # draw bridge function
	# calculate distances
	var counter = 0
	var grass_placed = Vector2.ZERO # coordinates of latest bridge tile placed
	var x_start = 0
	for j in y_dist: # move along y
		if j >= 1: # so the bridge doesn't replace the log 
			if y2-y1 <= 0: # if target y is above base y
				# move up
				$TileMap.set_cell(x1, y1-j, (counter%2)+3)
				grass_placed = Vector2(x1, y1-j)
				bridge_tiles.append(grass_placed)  # track each bridge tile for sinking
				counter += 1
			else:
				# move down
				$TileMap.set_cell(x1, y1+j, (counter%2)+3)
				grass_placed = Vector2(x1, y1+j)
				bridge_tiles.append(grass_placed)
				counter += 1
		yield(get_tree().create_timer(0.1), "timeout") # delay each tile placed
			
			
	if y_dist == 0: # if it is completely horizontal, make x start one ahead so it doesn't delete the log
		x_start = 1
	
	for k in range(x_start,x_dist): 	# move along x
#		if k >= 1: # so the bridge doesn't replace the log
			if x2-x1<= 0: # if target x is left to base x
				# move left
				$TileMap.set_cell(x1-k, y2, (counter%2)+3)
				grass_placed = Vector2(x1-k, y2)
				bridge_tiles.append(grass_placed)
				counter += 1
			else:
				# move right
				$TileMap.set_cell(x1+k, y2, (counter%2)+3)
				grass_placed = Vector2(x1+k, y2)
				bridge_tiles.append(grass_placed)
				counter += 1
			yield(get_tree().create_timer(0.1), "timeout")


func _hide(): # hide the letter input interface
	$CanvasLayer/Control.visible = false
	$TileMap.set_cell(plank_tile.x, plank_tile.y, 2)
	$TileMap2.set_cell(last_tile.x, last_tile.y, -1)
	for x in lineEdit.max_length+2:
		get_node("CanvasLayer/Control/MarginContainer/HBoxContainer/Let" + str(x+1)).queue_free()
	Engine.time_scale = lerp(slow_scale, 1.00, 0.75)
	water1.fps = 8
	water2.fps = 8
	log1.fps = 6
	log2.fps = 6
	grass1.fps = 4
	grass2.fps = 4
	grass3.fps = 4z
	grass4.fps = 4 #go back to normal time
	log_lock = false
	$Player.move = true # unlock and player can move
	$CanvasLayer/Control.process = false
	lineEdit.clear() # clear input


func _on_Control_word_found(): # if the entered word is valid
	_hide()
	draw_bridge(last_tile.x, last_tile.y, plank_tile.x, plank_tile.y) # draws bridge from last tile to selected plank tile
	
	if bridges_drawn >=2 && bridge_tiles.size() < 1: # if there are no bridges and tiles will sink,
		bridges_drawn = 0 # tiles will not sink for a second
		yield(get_tree().create_timer(1), "timeout") # gives player time to get on the bridge before it sinks
		bridges_drawn = 1
	bridges_drawn += 1 # bridges will now start sinking again because var is >= 2

	last_tile.x = plank_tile.x
	last_tile.y = plank_tile.y # track current tile 


	log_lock = false # lock off


func _on_Timer_timeout(): # sinking the first tiles
	if bridges_drawn >=  2 && bridge_tiles.size() > 0: # if there has been 2 bridges and bridge tiles
			$TileMap.set_cell(bridge_tiles[0].x,bridge_tiles[0].y, 5)
			grass3.set_current_frame(0)
			timer_count += 1
			yield(get_tree().create_timer(0.5), "timeout")

func _on_Timer2_timeout(): # sinking second tile then resetting first tile
	if bridges_drawn >= 2 && bridge_tiles.size() > 0 && timer_count > 0:  # at least o
		if timer_count % 2 == 0: # even # of sinking tiles exist to sink first one
			if bridge_tiles.size() > 1:
				$TileMap.set_cell(bridge_tiles[1].x,bridge_tiles[1].y, 6)
				grass4.set_current_frame(0)
				timer_count += 1
			$TileMap.set_cell(bridge_tiles[0].x,bridge_tiles[0].y, int(bridge_tiles[0].y)%2)
			bridge_tiles.remove(0) # remove he tile after sinking
