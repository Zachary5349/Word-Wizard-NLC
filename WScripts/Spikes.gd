extends AnimatedSprite

var vanish = 10

func _ready():
	#sets frame to 0 then starts
	frame = 0
	play()

func _on_Timer_timeout(): # stops animation
	stop()

func _process(delta):
	#if vanish is more than 1, opacity at 0
	if vanish >= 1:
		self_modulate.a = 1
	else: #otherwize increase opacity by vanish
		self_modulate.a = vanish
	vanish -= .08 #reduce vanish
	if vanish <= 0: #vanish set to 0 if below 0
		vanish = 0
