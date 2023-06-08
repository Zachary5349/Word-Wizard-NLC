extends Node2D

#signal HealthUpdate(attack_damage)
#signal HealthUpdate2(attack_damage)

func _ready():
	Master.mode = "mp"


func _process(delta):
	
	if $Player1.global_position.y > $Player2.global_position.y:
		$Player1.z_index = 3
		$Player2.z_index = 2
	else:
		$Player2.z_index = 3
		$Player1.z_index = 2
	

#
#func _on_Player1_HealthUpdate(attack_damage):
#	emit_signal("HealthUpdate", attack_damage)
#
#
#func _on_Player2_HealthUpdate(attack_damage):
#	emit_signal("HealthUpdate2", attack_damage)
