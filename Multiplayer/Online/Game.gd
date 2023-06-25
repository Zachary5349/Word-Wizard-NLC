extends Node2D

var current_spawn_location_instance_number = 1
var current_player_for_spawn_location_number = null


func _ready():
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	if get_tree().is_network_server():
		setup_players_positions()
		
func setup_players_positions() -> void:
	for player in Persistent_Nodes.get_children():
		if player.is_in_group("OnlinePlayer"):
			var spawns = $Spawn_locations.get_children()
#			print(spawns.size())
			for i in range(0, spawns.size()):
#				print(spawns[i])
#				print("oooobod")
#				print(int(spawns[i].name) == current_spawn_location_instance_number)
				if int(spawns[i].name) == current_spawn_location_instance_number and current_player_for_spawn_location_number != player:
					player.rpc("update_position", spawns[i].global_position)
					player.rset("global_position", spawns[i].global_position)
					current_spawn_location_instance_number += 1
					current_player_for_spawn_location_number = player
					
func _player_disconnected(id) -> void:
	if Persistent_Nodes.has_node(str(id)):
		Persistent_Nodes.get_node(str(id)).username_text_instance.queue_free()
		Persistent_Nodes.get_node(str(id)).hp = -1
