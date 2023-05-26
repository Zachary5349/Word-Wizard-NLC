extends Sprite

var tilex_index = 0
var tiley_index = 0
var created = false

#sets the z_index to a high number to make sure it apears in front of everything else,
#then sets the tile offset to ensure the text appears from left to right
func _ready():
	visible = false
	z_index = 999
	tilex_index = -18
	tiley_index = -8

func _process(delta):
	pass

func _on_Battle_Scene_hud(visibility, words):
	var letter_index = 0
	visible = visibility
	
	#for loop used to filter through each word withing the list given
	for each_word in words:
		tilex_index = -each_word.length()*2-each_word.length()/3
		#filters through each letter within the current word 
		for letter in each_word:
			letter_index = 0
			#filters through each letter in the alphabet then checks if the current letter
			#in the word is equal to the current letter in the alphabet
			for letter1 in "abcdefghijklmnopqrstuvwxyz":
				#in the case where the current letters match, it sets the tile of the tile map
				#to the current letter selected
				if letter == letter1:
					if visibility:
						$Text.set_cell(tilex_index,tiley_index,letter_index)
					else:
						$Text.set_cell(tilex_index,tiley_index,27)
					tilex_index += 5
				letter_index += 1
		tiley_index += 6
	tilex_index = -18
	tiley_index = -8
