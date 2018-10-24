extends Control

const PROJECTION_PLANE_DISTANCE = 277
const FOV = 60

export (int) var grid_unit_size = 64

var screensize
var angle_between_rays
var aY
var aX

func cast_rays(player):
	var player_rotation = player.get_rotation()
	var player_position = player.get_position_as_int()
	var ray_degree = (player_rotation - 30) if player_rotation >= 30 else (360 + (player_rotation - 30))
	var ray_count = 0
	while ray_count <= FOV:
		_cast_ray(player_position, ray_degree)
		if ray_degree == 359:
			ray_degree = 0
		else:
			ray_degree += 1
		ray_count += 1

func _ready():
	screensize = get_viewport_rect().size
	angle_between_rays = FOV / screensize.x

func _draw():
	pass

func _cast_ray(player_position, ray_degree):
	_check_horizontal_intersections(player_position, ray_degree)
	
func _check_horizontal_intersections(player_position, ray_degree):
	if (ray_degree >= 0 or ray_degree <= 180):
		aY = int(
			(floor(player_position.y / grid_unit_size) * grid_unit_size - 1)
			/ grid_unit_size
		)
	else:
		aY = int(
			(floor(player_position.y / grid_unit_size) * grid_unit_size + grid_unit_size)
			/ grid_unit_size
		)
	aX = int( 
		floor(player_position.x + (player_position.y - aY) / tan(deg2rad(ray_degree + 0.0001)))
		/ grid_unit_size
	)