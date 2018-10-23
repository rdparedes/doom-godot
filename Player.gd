extends Area2D

export (int) var angular_velocity
export (int) var speed
var screensize

func get_angle():
	return int(abs(rotation_degrees))
	
func get_position_as_int():
	return {
		"x": int(position.x),
		"y": int(position.y)
	}

func _ready():
	screensize = get_viewport_rect().size

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		_rotate_left(delta)
	if Input.is_action_pressed("ui_right"):
		_rotate_right(delta)
	if Input.is_action_pressed("ui_up"):
		_move_forward(delta)
	if Input.is_action_pressed("ui_down"):
		_move_backwards(delta)

func _rotate_right(delta):
	rotation_degrees += (delta * angular_velocity)
	if rotation_degrees > 0:
		rotation_degrees = -359
	
func _rotate_left(delta):
	rotation_degrees -= (delta * angular_velocity)
	if rotation_degrees <= -360:
		rotation_degrees = 0

func _move_forward(delta):
	position.x += (delta * speed) * cos(rotation)
	position.y += (delta * speed) * sin(rotation)
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)

func _move_backwards(delta):
	position.x -= (delta * speed) * cos(rotation)
	position.y -= (delta * speed) * sin(rotation)
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)
