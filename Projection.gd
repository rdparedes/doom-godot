extends Control

const PROJECTION_PLANE_DISTANCE = 277
const FOV = 60

export (int) var grid_unit_size = 64

var screensize
var angle_between_rays
var horizontal_x_intersection
var horizontal_y_intersection
var vertical_x_intersection
var vertical_y_intersection
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
	var horizontal_ray_collision = _check_horizontal_intersections(player_position, ray_degree)
	var vertical_ray_collision = _check_vertical_intersections(player_position, ray_degree)

func _check_horizontal_intersections(player_position, ray_degree):
	var i = 0
	var is_facing_up = (ray_degree >= 0 and ray_degree <= 180)

	while (true):
		if i == 0:
			horizontal_y_intersection = _find_first_Y_h_intersection(ray_degree, player_position, is_facing_up)
			horizontal_x_intersection = _find_first_X_h_intersection(ray_degree, player_position, horizontal_y_intersection)
			var grid_x_coords = int(horizontal_x_intersection / grid_unit_size)
			var grid_y_coords = int(horizontal_y_intersection / grid_unit_size)
			i += 1
			if _wall_exists(grid_x_coords, grid_y_coords):
				return Vector2(horizontal_x_intersection, horizontal_y_intersection)
		else:
			horizontal_y_intersection += _find_next_Y_h_intersection(is_facing_up)
			horizontal_x_intersection += _find_next_X_h_intersection(ray_degree)
			var grid_x_coords = int(horizontal_x_intersection / grid_unit_size)
			var grid_y_coords = int(horizontal_y_intersection / grid_unit_size)
			if _wall_exists(grid_x_coords, grid_y_coords):
				return Vector2(horizontal_x_intersection, horizontal_y_intersection)
			if horizontal_y_intersection < 0 or horizontal_y_intersection > screensize.y \
				or horizontal_x_intersection < 0 or horizontal_x_intersection > screensize.x:
					break

func _wall_exists(x, y):
	return map_representation.has([x, y])

func _find_first_Y_h_intersection(ray_degree, player_position, is_facing_up):
	if is_facing_up:
		return ((floor(player_position.y / grid_unit_size) * grid_unit_size) - 1)
	else:
		return (floor(player_position.y / grid_unit_size) * grid_unit_size + grid_unit_size)

func _find_first_X_h_intersection(ray_degree, player_position, horizontal_y_intersection):
	return floor(player_position.x + ((player_position.y - horizontal_y_intersection) / tan(deg2rad(ray_degree + 0.0001))))

func _find_next_Y_h_intersection(is_facing_up):
	return -grid_unit_size if is_facing_up else grid_unit_size

func _find_next_X_h_intersection(ray_degree):
	return floor(grid_unit_size / tan(deg2rad(ray_degree + 0.0001)))

func _check_vertical_intersections(player_position, ray_degree):
	var i = 0
	var is_facing_right = (ray_degree >= 0 and ray_degree <= 90 \
								or ray_degree >= 270 and ray_degree <= 360)

	while (true):
		if i == 0:
			vertical_x_intersection = _find_first_X_v_intersection(ray_degree, player_position, is_facing_right)
			vertical_y_intersection = _find_first_Y_v_intersection(ray_degree, player_position, vertical_x_intersection)
			var grid_x_coords = int(vertical_x_intersection / grid_unit_size)
			var grid_y_coords = int(vertical_y_intersection / grid_unit_size)
			i += 1
			if _wall_exists(grid_x_coords, grid_y_coords):
				return Vector2(vertical_x_intersection, vertical_y_intersection)
		else:
			vertical_x_intersection += _find_next_X_v_intersection(is_facing_right)
			vertical_y_intersection += _find_next_Y_v_intersection(ray_degree)
			var grid_x_coords = int(vertical_x_intersection / grid_unit_size)
			var grid_y_coords = int(vertical_y_intersection / grid_unit_size)
			if _wall_exists(grid_x_coords, grid_y_coords):
				return Vector2(vertical_x_intersection, vertical_y_intersection)
			if vertical_y_intersection < 0 or vertical_y_intersection > screensize.y \
				or vertical_x_intersection < 0 or vertical_x_intersection > screensize.x:
					break

func _find_first_X_v_intersection(ray_degree, player_position, is_facing_right):
	if is_facing_right:
		return ((floor(player_position.x / grid_unit_size) * grid_unit_size) + grid_unit_size)
	else:
		return (floor(player_position.x / grid_unit_size) * grid_unit_size - 1)

func _find_first_Y_v_intersection(ray_degree, player_position, vertical_x_intersection):
	return floor(player_position.y + ((player_position.x - vertical_x_intersection) * tan(deg2rad(ray_degree))))

func _find_next_X_v_intersection(is_facing_right):
	return grid_unit_size if is_facing_right else -grid_unit_size

func _find_next_Y_v_intersection(ray_degree):
	return floor(grid_unit_size * tan(deg2rad(ray_degree)))