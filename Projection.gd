extends Control

const PROJECTION_PLANE_DISTANCE = 277
const FOV = 60

export (int) var grid_unit_size = 64

var screensize
var angle_between_rays
var x_intersection
var y_intersection
var map_representation		# Contains an array representing all coordinates that have a wall

func cast_rays(player):
	var player_rotation = player.get_rotation()
	var player_position = player.get_position_as_int()
	var ray_degree = (player_rotation - 30) if player_rotation >= 30 else (360 + (player_rotation - 30))
	var ray_count = 0
	#while ray_count <= FOV:
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
	var i = 0
	var is_facing_up = (ray_degree >= 0 and ray_degree <= 180)

	while (true):
		if i == 0:
			y_intersection = _find_first_Y_intersection(ray_degree, player_position, is_facing_up)
			x_intersection = _find_first_X_intersection(ray_degree, player_position, y_intersection)
			var x_coords = int(x_intersection / grid_unit_size)
			var y_coords = int(y_intersection / grid_unit_size)
			i += 1
			if _wall_exists(x_coords, y_coords):
				print('hit a wall!')
				break
		else:
			y_intersection += _find_next_Y_intersection(is_facing_up)
			x_intersection += _find_next_X_intersection(ray_degree)
			var x_coords = int(x_intersection / grid_unit_size)
			var y_coords = int(y_intersection / grid_unit_size)
			if _wall_exists(x_coords, y_coords):
				print('hit a wall!')
				break
			if y_intersection < 0 or y_intersection > screensize.y \
				or x_intersection < 0 or x_intersection > screensize.x:
					break

func _wall_exists(x, y):
	return map_representation.has([x, y])

func _find_first_Y_intersection(ray_degree, player_position, is_facing_up):
	if is_facing_up:
		return ((floor(player_position.y / grid_unit_size) * grid_unit_size) - 1)
	else:
		return (floor(player_position.y / grid_unit_size) * grid_unit_size + grid_unit_size)

func _find_first_X_intersection(ray_degree, player_position, y_intersection):
	return floor(player_position.x + ((player_position.y - y_intersection) / tan(deg2rad(ray_degree + 0.0001))))

func _find_next_Y_intersection(is_facing_up):
	return -grid_unit_size if is_facing_up else grid_unit_size

func _find_next_X_intersection(ray_degree):
	return floor(grid_unit_size / tan(deg2rad(ray_degree + 0.0001)))
