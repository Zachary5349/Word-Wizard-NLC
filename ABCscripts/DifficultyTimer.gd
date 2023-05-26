extends Timer

func start_timer() -> void:
	wait_time = 3.0
	connect("timeout", self, "printHello")
	start()

func printHello():
	print("hello")



