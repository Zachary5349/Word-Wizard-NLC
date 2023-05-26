extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func process(delta):
	if current == true:
		lerp(global_position, get_parent().get_node("Giant_Worm").global_position, 0.75)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
