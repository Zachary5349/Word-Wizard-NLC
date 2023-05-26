extends Sprite
var time = 0
var state = 0

func _ready():
	pass

func _process(delta):
	#forever increases time
	time += .01
	
	#inscreases scale based on a sin curve
	scale.x = 1 + sin(time)/7
	scale.y = 1 + sin(time)/7
	
	#increases rotation
	rotation += .01
	
	#detects if it should be visible or not
	if state == 0:
		visible = false
	else:
		visible = true
