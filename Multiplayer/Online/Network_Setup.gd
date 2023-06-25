extends Control

var player = load("res://Multiplayer/Online/WizardOnline.tscn")
var player2 = load("res://Multiplayer/Online/WizardOnline2.tscn")

onready var multiplayer_config_ui = $Multiplayer_Configure
onready var username_text_edit = $Multiplayer_Configure/Username_text_edit

onready var device_ip_address = $CanvasLayer/Device_ip_address
onready var start_game = $CanvasLayer/Start_game

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	device_ip_address.text = Network.ip_address
	if get_tree().network_peer != null:
		pass
	else:
		start_game.hide()

func _process(delta):
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
			start_game.show()
		else:
			start_game.hide()
			

func _player_connected(id) -> void:
	print("Player " + str (id) + " has connected")
	
	instance_player(id)
	
func _player_disconnected(id) -> void:
	print("Player " + str (id) + " has disconnected")
	if Persistent_Nodes.has_node(str(id)):
		Persistent_Nodes.get_node(str(id)).username_text_instance.queue_free()
		Persistent_Nodes.get_node(str(id)).queue_free()

func _on_Create_Server_pressed():
	if username_text_edit.text != "":
		Network.current_player_username = username_text_edit.text
		username_text_edit.hide()
		multiplayer_config_ui.hide()
		Network.create_server()

		instance_player(get_tree().get_network_unique_id())
	
func _on_Join_Server_pressed():
	if username_text_edit.text != "":
		multiplayer_config_ui.hide()
		username_text_edit.hide()
		Global.instance_node(load("res://Multiplayer/Online/Server_Browser.tscn"), self)
#		Network.ip_address = username_text_edit.text
#		Network.join_server()

func _connected_to_server() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())

func instance_player(id) -> void:
	var player_instance
	if id == 1:
		player_instance = Global.instance_node_at_location(player, Persistent_Nodes, Vector2(83, 197))
	else:
		player_instance = Global.instance_node_at_location(player2, Persistent_Nodes, Vector2(601, 197))
	player_instance.name = str(id)
	player_instance.set_network_master(id)
	player_instance.username = username_text_edit.text
	player_instance.username = username_text_edit.text


func _on_Start_game_pressed():
	rpc("switch_to_game")

sync func switch_to_game() -> void:
	for child in Persistent_Nodes.get_children():
		if child.is_in_group("OnlinePlayer"):
			child.can_shoot = true
	get_tree().change_scene("res://Multiplayer/Online/Game.tscn")
