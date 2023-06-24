extends Label

var ip_address = ""

func _on_join_pressed():
	Network.ip_address = ip_address
	Network.joinserver()
	get_parent().get_parent().queue_free()
