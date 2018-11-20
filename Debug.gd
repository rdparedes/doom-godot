extends CanvasLayer

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func update_player_angle(angle):
	$Angle/Value.text = str(angle)

func update_player_position(position):
	$Position/Value.text = str(position.x, ", ", position.y)

func update_ray(r):
	if not r:
		r = { "x": -1, "y": -1 }
	$Ray/Value.text = str("x: ", r.x, ", y: ", r.y)
	$HIntersection.x = r.x
	$HIntersection.y = r.y
	$HIntersection.update()
