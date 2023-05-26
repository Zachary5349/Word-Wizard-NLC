extends Control

# word list
onready var file = 'res://words_alpha.txt' # .txt file hlding english words

var file_list = Array()
var found = false
var process = true

var template_let_slot = preload("res://Scenes/LetterSlot.tscn")

signal word_found # signal for when the word is entered and valid


func _ready() -> void: # when the program starts, the sorting happens, so there isn't a significant drop on in-game performance because of this method processing
	var f = File.new()
	f.open(file, File.READ)
	# iterate through all lines until the end of file
	while not f.eof_reached():
		var line = f.get_line() # get the next line in the file
		file_list.append(line) # put the .txt file into an accessable array
	f.close()


func _process(delta):
	if process == true:
		for x in $LineEdit.max_length: # for the num of letters in the prompt
			var icon_texture = load("res://Assets/letters/blank.png")
			get_node("MarginContainer/HBoxContainer/Let"+ str(x+2) + "/Icon").set_texture(icon_texture) # reset each letter to placeholder (to update word and backspaces)
			# cursor flashing
			# the cursor is a texture node within each letter box turned on or off
			# hide cursor to reset/update
			get_node("MarginContainer/HBoxContainer/Let"+ str(x+2) + "/selectf").visible = false 
			get_node("MarginContainer/HBoxContainer/Let"+ str(x+2) + "/selectb").visible = false
			# set the highlight at the lineedit's cursor position; show cursor
			if x == $LineEdit.caret_position:
				get_node("MarginContainer/HBoxContainer/Let"+ str($LineEdit.caret_position+2)+"/selectf").visible = true 
			if x+1 == $LineEdit.caret_position:
				get_node("MarginContainer/HBoxContainer/Let"+ str($LineEdit.caret_position+1)+"/selectb").visible = true
			
		
		for i in $LineEdit.text.length(): # for the num of letters in the typed text
			if $LineEdit.text[i].to_lower() in "abcdefghijklmnopqrstuvwxyz": # if it is a letter (not special character or num like 123#$@/.etc)
				# update tiles to match letters
				var icon_texture = load("res://Assets/letters/"+ $LineEdit.text[i].to_lower() + ".png") # get the right letter image
				get_node("MarginContainer/HBoxContainer/Let"+ str(i+2) + "/Icon").set_texture(icon_texture) # set the node's texture to the letter
			else:
				$LineEdit.delete_char_at_cursor() # if special character or num, delete it
		$Label4.text = ("Length: " + str($LineEdit.max_length)) 


func _show(length):
	visible = true
	var size = 0  # size of letter box
	$LineEdit.grab_focus() # player can start typing
	$LineEdit.max_length = length # make sure player can't type more than distance
	if $LineEdit.max_length <= 5: # formatting methods
		# max width of letters is 95 x 95px
		size = 95
	else: 
	# else the distance is longer than 5, we calculate the width of each letter to fit on the screen
	# this allows for any length of words to fit on the screen by adjusting the letter slot sizes with a max horiz. margin
		size = (672/($LineEdit.max_length)-(150/$LineEdit.max_length)) 
		
	for x in $LineEdit.max_length+2: # for word length + 2 sidebars
		var blank_slot_new = template_let_slot.instance() # load letter slot into var
		blank_slot_new.rect_min_size = Vector2(size,size)
		
		# start and end letter slots with left and right margins
		if x == 0: 
			var icon_texture = load("res://Assets/letters/left.png")
			blank_slot_new.get_node("Icon").set_texture(icon_texture)
			
		elif x == ($LineEdit.max_length+1):
			var icon_texture = load("res://Assets/letters/right.png")
			blank_slot_new.get_node("Icon").set_texture(icon_texture)
		else:
			# reset each letter to blank slot to match input
			var icon_texture = load("res://Assets/letters/blank.png")
			blank_slot_new.get_node("Icon").set_texture(icon_texture)
		$MarginContainer/HBoxContainer.add_child(blank_slot_new, true) # add node whatever was set (left, right or blank)
	# process for caret
	process = true 


func _hide():
	if visible == true:
		visible = false 
		process = false
		for x in $LineEdit.max_length+2:
			get_node("MarginContainer/HBoxContainer/Let" + str(x+1)).queue_free() 
		$LineEdit.clear() # clear input


func _on_LineEdit_text_entered(new_text):
	if new_text.length() == $LineEdit.max_length: # make sure that it the right size
		if file_list.has(new_text.to_lower()): # check if word is valid
			found = true
	if found == true:
		print(new_text)
		$correct.play()
		emit_signal("word_found") # signal for when the word is found 
		found = false
	else:
		$AnimationPlayer.play("shake") # shake ui
		$wrong.play()


func _on_LineEdit_text_changed(new_text):
	$click.play()
