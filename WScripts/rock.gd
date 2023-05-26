extends Sprite

var speed = 0
var xdist = 0
var target = Vector2.ZERO
var target_global = Vector2.ZERO
var grav = 0
var rot_degree

func _ready():
	#allows randomizations
	randomize()
	
	#sets speed to distance from target
	speed = sqrt((target.x-position.x)*(target.x-position.x) + (target.y-position.y)*(target.y-position.y))
	
	#sets the gravity and x distance 
	xdist = target.x - position.x
	grav = speed*2 - (target.y - position.y)
	
	#sets the rotation modifier to a random number
	rot_degree = rand_range(0.07,0.15)

func _process(delta):
	#changes position by values based on distance
	position.x += xdist/(60*1.5) * Engine.time_scale
	position.y -= grav/(60*1.5) * Engine.time_scale
	
	#increases the gravity, rotation, and degree of rotation
	grav -= speed/(71*.37) * Engine.time_scale
	rotation += rot_degree * Engine.time_scale
	rot_degree /= (.015 * Engine.time_scale) + 1
	
