extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Master.mode = "mp"


func _process(delta):
	
	if $Player1.global_position.y > $Player2.global_position.y:
		$Player1.z_index = 3
		$Player2.z_index = 2
	else:
		$Player2.z_index = 3
		$Player1.z_index = 2
	print(str($Player1.z_index) + " " + str($Player2.z_index))
	
