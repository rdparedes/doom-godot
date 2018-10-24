extends KinematicBody2D

export (int) var angular_velocity
export (int) var speed

var velocity = Vector2()
var screensize

func get_rotation():
	return int(
		abs(global_rotation_degrees) if global_rotation_degrees <= 0 else (360 - global_rotation_degrees)
	)
	
func get_position_as_int():
	return {
		"x": int(position.x),
		"y": int(position.y)
	}

func _ready():
	screensize = get_viewport_rect().size
	
func _physics_process(delta):
	if Input.is_action_pressed("ui_up"):
		_move_forward()
	if Input.is_action_pressed("ui_down"):
		_move_backwards()
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		_rotate_left(delta)
	if Input.is_action_pressed("ui_right"):
		_rotate_right(delta)

func _rotate_right(delta):
	rotation += (delta * angular_velocity)
	
func _rotate_left(delta):
	rotation -= (delta * angular_velocity)

func _move_forward():
	velocity = Vector2(speed * cos(rotation), speed * sin(rotation))
	move_and_slide(velocity)

func _move_backwards():
	velocity = Vector2(speed * cos(rotation), speed * sin(rotation))
	move_and_slide(-velocity)
