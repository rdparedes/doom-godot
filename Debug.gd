extends CanvasLayer

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func update_player_angle(angle):
	$Angle/Value.text = str(angle)

func update_player_position(position):
	$Position/Value.text = str(position.x, ", ", position.y)

func update_ray(hx, hy, vx, vy):
	$Ray/Value.text = str("x: ", hx, ", y: ", hy)
	$HIntersection.x = hx
	$HIntersection.y = hy
	$VIntersection.x = vx
	$VIntersection.y = vy
	$HIntersection.update()
	$VIntersection.update()
