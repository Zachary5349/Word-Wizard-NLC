extends Label

func _ready():
	randomize()
	var rand = randf()
	if Master.current == "worm":
		if rand <= 1.0/3.0:
			text = "Make sure to avoid the falling rocks!"
		elif rand <= 2.0/3.0:
			text = "Keep on your toes! Dont get hit by the worm!"
		else:
			text = "Some words repeat, look out for the ones that do!"
	
	if Master.current == "kraken":
		if rand <= 1.0/3.0:
			text = "Watch out for the krakens attack!"
		elif rand <= 2.0/3.0:
			text = "Try to find the best path to easily dodge the water blast!"
		else:
			text = "Reuse words if you can! Theres no shame in doing so!"
	
	if Master.current == "dragon":
		if rand <= 1.0/3.0:
			text = "This ones tough, dont worry if you die."
		elif rand <= 2.0/3.0:
			text = "Keep on trying! Practice makes perfect!"
		else:
			text = "Youll get it eventually!"
