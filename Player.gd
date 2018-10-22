extends Area2D

export (int) var angular_velocity

func get_angle():
	return int(abs(rotation_degrees))

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		_rotate_left(delta)
	if Input.is_action_pressed("ui_right"):
		_rotate_right(delta)
	if Input.is_action_pressed("ui_up"):
		_move_forward(delta)

func _rotate_right(delta):
	rotation_degrees += (delta * angular_velocity)
	if rotation_degrees > 0:
		rotation_degrees = -359
	
func _rotate_left(delta):
	rotation_degrees -= (delta * angular_velocity)
	if rotation_degrees <= -360:
		rotation_degrees = 0

func _move_forward(delta):
	pass