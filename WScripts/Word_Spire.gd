extends KinematicBody2D

var word_list = ["wizard","magic","fire","water","rock","spells","spell","element",
	"elements","wizards","worm","behemoth","kraken","obelisk","flame","dragon"]
var words = []
var can_use = false
var scrambled_list = []
var current_letter = 0
var index = 0

func _ready():
	randomize() #allows randomization
	$Enter_key.visible = false
	
	#starts picking words, if the word is the same as another then it chooses another
	words.append(word_list[randi() % word_list.size()-1])
	words.append(word_list[randi() % word_list.size()-1])
	if words[1] == words[0]:
		words.remove(1)
		words.append(word_list[randi() % word_list.size()-1])
	words.append(word_list[randi() % word_list.size()-1])
	if words[2] == words[0] or words[2] == words[1]:
		words.remove(2)
		words.append(word_list[randi() % word_list.size()-1])
	
	#starts scrambling the words
	for wrd in words:
		scrambled_list.append(scramble(wrd))
	for scrmbled_word in scrambled_list:
		var index = 0
		for word in words:
			if scrmbled_word == word:
				scrambled_list[index] = scramble(word)
		index += 1

func _process(delta):
	#prevents usage if solved already
	if index > 2:
		can_use = false

func _on_Area2D_body_entered(body):
	#when the player enters the area, it can be used
	$Enter_key.visible = true
	can_use = true

func _on_Area2D_body_exited(body):
	#when the player exits, it cant be used
	$Enter_key.visible = false
	can_use = false

func scramble(word):
	#scrambles the word by picking a random letter in the word, then picking another and checking 
	#if that letter was laready used, then repeating until scrambled
	var used = []
	var scrambled = false
	var scrambled_word = []
	while not scrambled:
		var used_already = false
		var num = randi() % word.length()
		for use in used:
			if num == use:
				used_already = true
		if not used_already:
			used.append(num)
			scrambled_word.append(word[num])
		if word.length() == scrambled_word.size():
			return(array_to_string(scrambled_word))

#converts the array to a string
func array_to_string(array):
	var strng = ""
	for let in array:
		strng += String(let)
	return strng
