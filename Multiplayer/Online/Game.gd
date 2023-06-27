extends Node2D
#
#var current_spawn_location_instance_number = 1
#var current_player_for_spawn_location_number = null

var p1_shots = 0
var p2_shots = 0
var p1_total = 0
var p2_total = 0

var done = false

signal turns_end

func _ready():
	get_tree().reload_current_scene()
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
			turn1()
		else:
			turn2()
	pass
#	yield($turn1_timer, "timeout")
#	print("timerrr")
##	print_tree()
#	print("turnessssssss ended")
#	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
#	for child in Persistent_Nodes.get_children():
#		if child.is_in_group("OnlinePlayer"):
##			if child.name == "1":
##				child.update_positions()
#			child.can_shoot = true

func turn1():
	$turn1_timer.start()
	while $turn1_timer.time_left > 0:
		randomize()
		$CanvasLayer/Input1._show((randi()%5+3))
		yield($CanvasLayer/Input1, "word_found")
		p1_shots += 1
		$CanvasLayer/Input1._hide()
		rset("p1_shots", p1_shots)
		print("p1_shots " + str(p1_shots))
		yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("turns_end")
	
func turn2():
	$turn2_timer.start()
	while $turn2_timer.time_left > 0:
		randomize()
		$CanvasLayer/Input2._show((randi()%5+3))
		yield($CanvasLayer/Input2, "word_found")
		p2_shots += 1
		$CanvasLayer/Input2._hide()
		rset("p2_shots", p2_shots)
		print("p2_shots " + str(p2_shots))
		yield(get_tree().create_timer(0.5), "timeout")
#	$CanvasLayer/Input1._end(2)
	emit_signal("turns_end")
	
		
#	emit_signal("turn1_end")


#	if get_tree().is_network_server():
#		setup_players_positions()
#
#func setup_players_positions() -> void:
#	for player in Persistent_Nodes.get_children():
#		if player.is_in_group("OnlinePlayer"):
#			var spawns = $Spawn_locations.get_children()
##			print(spawns.size())
#			for i in range(0, spawns.size()):
##				print(spawns[i])
##				print("oooobod")
##				print(int(spawns[i].name) == current_spawn_location_instance_number)
#				if int(spawns[i].name) == current_spawn_location_instance_number and current_player_for_spawn_location_number != player:
#					player.rpc("update_position", spawns[i].global_position)
#					player.rset("global_position", spawns[i].global_position)
#					current_spawn_location_instance_number += 1
#					current_player_for_spawn_location_number = player


func _process(delta):
	if done:
		if get_tree().network_peer != null:
			if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
				for child in Persistent_Nodes.get_children():
					if child.is_in_group("OnlinePlayer") and child.name == "1":
						p1_shots = child.shots
				if p1_shots >= 10:
					$CanvasLayer/shots1.text = str(p1_shots)
				else:
					$CanvasLayer/shots1.text = "0" + str(p1_shots)
			else:
				for child in Persistent_Nodes.get_children():
					if child.is_in_group("OnlinePlayer") and child.name != "1":
						p2_shots = child.shots
				if p2_shots >= 10:
					$CanvasLayer/shots1.text = str(p2_shots)
				else:
					$CanvasLayer/shots1.text = "0" + str(p2_shots)
		for child in Persistent_Nodes.get_children():
			if child.is_in_group("OnlinePlayer"):
				child.move = true
				child.can_shoot = true
	else:
		if get_tree().network_peer != null:
			if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
				if int($turn1_timer.time_left) >= 10:
					$CanvasLayer/Label2.text = "00:" + str(int($turn1_timer.time_left))
				elif int($turn1_timer.time_left) > 0:
					$CanvasLayer/Label2.text = "00:0" + str(int($turn1_timer.time_left))
				else:
					$CanvasLayer/Label2.text = "00:00"
			else:
				if int($turn2_timer.time_left) >= 10:
					$CanvasLayer/Label2.text = "00:" + str(int($turn2_timer.time_left))
				elif int($turn2_timer.time_left) > 0:
					$CanvasLayer/Label2.text = "00:0" + str(int($turn2_timer.time_left))
				else:
					$CanvasLayer/Label2.text = "00:00"
	for child in Persistent_Nodes.get_children():
		if child.is_in_group("OnlinePlayer"):
			if child.hp <= 0:
				if child.name == "1":
					if get_tree().network_peer != null:
						if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
							$CanvasLayer/Label.text = "You lost!"
						else:
							$CanvasLayer/Label.text = "You won!"
				else:
					if get_tree().network_peer != null:
						if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
							$CanvasLayer/Label.text = "You won!"
						else:
							$CanvasLayer/Label.text = "You lost!"
							
				yield(get_tree().create_timer(3), "timeout")
				get_tree().change_scene("res://Scenes/Title Screen.tscn")
		
					
func _player_disconnected(id) -> void:
	if Persistent_Nodes.has_node(str(id)):
		Persistent_Nodes.get_node(str(id)).username_text_instance.queue_free()
		Persistent_Nodes.get_node(str(id)).hp = -1


func _on_turn1_timer_timeout():
	$CanvasLayer/Input1._end(1)

func _on_turn2_timer_timeout():
	$CanvasLayer/Input2._end(2)


func _on_Game_turns_end():
	$CanvasLayer/Label2.hide()
	done = true
	$CanvasLayer/ColorRect.hide()
	$CanvasLayer/shots1/slash1.show()	
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	for child in Persistent_Nodes.get_children():
		if child.is_in_group("OnlinePlayer"):
			child.move = true
			child.can_shoot = true
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
			p1_total = p1_shots
			if p1_total >= 10:
				$CanvasLayer/shots12.text = str(p1_total)
			else:
				$CanvasLayer/shots12.text = "0" + str(p1_total)
			for child in Persistent_Nodes.get_children():
				if child.is_in_group("OnlinePlayer") and child.name == "1":
					child.shots = p1_total
		else:
			p2_total = p2_shots
			if p2_total >= 10:
				$CanvasLayer/shots12.text = str(p2_total)
			else:
				$CanvasLayer/shots12.text = "0" + str(p2_total)
			for child in Persistent_Nodes.get_children():
				if child.is_in_group("OnlinePlayer") and child.name != "1":
					child.shots = p2_total
