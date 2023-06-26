extends Camera2D

var target_player = null

func _ready() -> void:
	target_player = Global.player_master

#func _process(delta):
#	if Global.player_master != null:
#		print(Global.player_master.name)
#		global_position = Global.player_master.global_position
