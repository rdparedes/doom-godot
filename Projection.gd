extends Control

export (int) var grid_unit_size = 64
export (int) var player_speed = 6

const FOV = 60
const PROJECTION_PLANE_WIDTH = 320
const PROJECTION_PLANE_HEIGHT = 200
var PROJECTION_X_CENTER = PROJECTION_PLANE_WIDTH / 2
var PROJECTION_Y_CENTER = PROJECTION_PLANE_HEIGHT / 2

const ANGLE60 = PROJECTION_PLANE_WIDTH
var ANGLE30 = floor(ANGLE60/2)
var ANGLE15 = floor(ANGLE30/2)
var ANGLE90 = floor(ANGLE30*3)
var ANGLE180 = floor(ANGLE90*2)
var ANGLE270 = floor(ANGLE90*3)
var ANGLE360 = floor(ANGLE60*6)
const ANGLE0 = 0
var ANGLE5 = floor(ANGLE30/6)
var ANGLE10 = floor(ANGLE5*2)
var ANGLE45 = floor(ANGLE15*3)

var RAY_WIDTH = PROJECTION_PLANE_WIDTH / FOV
var PROJECTION_PLANE_DISTANCE = floor(PROJECTION_X_CENTER / tan(deg2rad(FOV / 2)))

# Trigonometric tables for quick calculations (the ones with "i" are inverse tables)
var f_sin_table = []
var f_i_sin_table = []
var f_cos_table = []
var f_i_cos_table = []
var f_tan_table = []
var f_i_tan_table = []
var f_fish_dict = {}
var f_x_step_table = []
var f_y_step_table = []

var player = {
  "position": Vector2(0, 0),
  "rotation": ANGLE0
}

var screensize

# Vars for debugging
var debug_first_ray
var debug_last_ray

# Array representing all coordinates that have a wall
var map_representation

var process_timer = 0
var process_timer_limit = 0.05

func arcToRad(angle):
  return ((angle*PI)/ANGLE180)

func _ready():
  screensize = get_viewport_rect().size

  # populate lookup tables with rad values
  var radian
  for i in range(0, ANGLE360 + 1):
    radian = arcToRad(i) + (0.0001)
    f_sin_table.append(sin(radian))
    f_i_sin_table.append(1.0/f_sin_table[i])
    f_cos_table.append(cos(radian))
    f_i_cos_table.append(1.0/f_cos_table[i])
    f_tan_table.append(tan(radian))
    f_i_tan_table.append(1.0/f_tan_table[i])

    # Table to speed up wall lookups

    #  You can see that the distance between walls are the same
    #  if we know the angle
    #  _____|_/next xi______________
    #       |
    #  ____/|next xi_________   slope = tan = height / dist between xi's
    #     / |
    #  __/__|_________  dist between xi = height/tan where height=tile size
    # old xi|
    #                  distance between xi = x_step[view_angle];
    # source: https://github.com/permadi-com/ray-cast/blob/master/demo/1/sample1.js

    # Facing LEFT
    if (i >= ANGLE90 && i < ANGLE270):
      f_x_step_table.append(grid_unit_size/f_tan_table[i])
      if f_x_step_table[i] > 0:
        f_x_step_table[i] = -f_x_step_table[i]
    # Facing RIGHT
    else:
      f_x_step_table.append(grid_unit_size/f_tan_table[i])
      if f_x_step_table[i] < 0:
        f_x_step_table[i] = -f_x_step_table[i]
    # Facing DOWN
    if (i >= ANGLE0 && i < ANGLE180):
      f_y_step_table.append(grid_unit_size*f_tan_table[i])
      if f_y_step_table[i] < 0:
        f_y_step_table[i] = -f_y_step_table[i]
    # Facing UP
    else:
      f_y_step_table.append(grid_unit_size*f_tan_table[i])
      if f_y_step_table[i] > 0:
        f_y_step_table[i] = -f_y_step_table[i]

  # Lookup table for Fishbowl distortion fix
  for i in range(-ANGLE30, ANGLE30 + 1):
    radian = arcToRad(i)
    f_fish_dict[int(i+ANGLE30)] = (1.0/cos(radian))

func _draw():
  _cast_rays()

func _process(delta):
  process_timer += delta
  if process_timer < process_timer_limit:
    return
  process_timer = 0
  if Input.is_action_pressed("ui_left"):
    _rotate_left(delta)
  if Input.is_action_pressed("ui_right"):
    _rotate_right(delta)

  var player_x_dir = f_cos_table[player.rotation]
  var player_y_dir = f_sin_table[player.rotation]

  if Input.is_action_pressed("ui_up"):
    _move_forward(player_x_dir, player_y_dir)
  if Input.is_action_pressed("ui_down"):
    _move_backwards(player_x_dir, player_y_dir)

func _rotate_right(delta):
  player.rotation += ANGLE10
  if player.rotation >= ANGLE360:
    player.rotation -= ANGLE360

func _rotate_left(delta):
  player.rotation -= ANGLE10
  if player.rotation < ANGLE0:
    player.rotation += ANGLE360

func _move_forward(player_x_dir, player_y_dir):
  player.position.x += round(player_x_dir * player_speed)
  player.position.y += round(player_y_dir * player_speed)

func _move_backwards(player_x_dir, player_y_dir):
  player.position.x -= round(player_x_dir * player_speed)
  player.position.y -= round(player_y_dir * player_speed)

func _draw_slice(ray_distance, ray_index):
  var projected_slice_height = grid_unit_size * PROJECTION_PLANE_DISTANCE / ray_distance
  draw_rect(
    Rect2(
      (PROJECTION_PLANE_WIDTH - ray_index),
      PROJECTION_Y_CENTER - int(projected_slice_height / 2),
      1,
      projected_slice_height
    ),
    Color("#FF0000")
  )

func _cast_rays():
  var ray_degree = player.rotation
  ray_degree -= ANGLE30
  if ray_degree < 0:
    ray_degree = ANGLE360 + ray_degree
  var ray_index = 0

  while ray_index <= PROJECTION_PLANE_WIDTH:
    var ray_distance = _cast_ray_and_return_distance(
      player.position,
      ray_degree,
      ray_index == 0,
      ray_index == PROJECTION_PLANE_WIDTH
    )
    if ray_distance:
      ray_distance /= f_fish_dict[ray_index]
      _draw_slice(ray_distance, ray_index)
    ray_degree += 1
    if ray_degree >= ANGLE360:
      ray_degree -= ANGLE360
    ray_index += 1

func _cast_ray_and_return_distance(player_position, ray_degree, is_first_ray, is_last_ray):
  var ray_rad = arcToRad(ray_degree)
  var horizontal_ray_collision = _check_horizontal_intersections(player_position, ray_degree)
  var vertical_ray_collision = _check_vertical_intersections(player_position, ray_degree)
  var ray_distance = null

  var debug_ray_intersection = null

  if horizontal_ray_collision and not vertical_ray_collision:
    debug_ray_intersection = horizontal_ray_collision
    ray_distance = abs(player_position.y - horizontal_ray_collision.y) / f_cos_table[ray_rad]
  elif vertical_ray_collision and not horizontal_ray_collision:
    debug_ray_intersection = vertical_ray_collision
    ray_distance = abs(player_position.x - vertical_ray_collision.x) / f_sin_table[ray_rad]
  elif vertical_ray_collision and horizontal_ray_collision:
    var distance_to_h = abs(player_position.y - horizontal_ray_collision.y) / f_cos_table[ray_rad]
    var distance_to_v = abs(player_position.x - vertical_ray_collision.x) / f_sin_table[ray_rad]

    ray_distance = min(distance_to_h, distance_to_v)

    debug_ray_intersection = horizontal_ray_collision \
            if floor(ray_distance) == floor(distance_to_h) else vertical_ray_collision

  # Draw FOV on screen for guide only
  if is_first_ray:
    debug_first_ray = debug_ray_intersection
  elif is_last_ray:
    debug_last_ray = debug_ray_intersection

  return ray_distance

func _check_horizontal_intersections(player_position, ray_degree):
  var i = 0
  var is_facing_down = (ray_degree > ANGLE0 and ray_degree < ANGLE180)
  var horizontal_x_intersection
  var horizontal_y_intersection

  while (true):
    if i == 0:
      horizontal_y_intersection = _find_first_Y_h_intersection(ray_degree, player_position, is_facing_down)
      horizontal_x_intersection = _find_first_X_h_intersection(ray_degree, player_position, horizontal_y_intersection)
      var grid_x_coords = int(horizontal_x_intersection / grid_unit_size)
      var grid_y_coords = int(horizontal_y_intersection / grid_unit_size)
      i += 1
      if _wall_exists(grid_x_coords, grid_y_coords):
        return Vector2(horizontal_x_intersection, horizontal_y_intersection)
    else:
      horizontal_y_intersection += _find_next_Y_h_intersection(is_facing_down)
      horizontal_x_intersection += _find_next_X_h_intersection(ray_degree, is_facing_down)
      var grid_x_coords = int(horizontal_x_intersection / grid_unit_size)
      var grid_y_coords = int(horizontal_y_intersection / grid_unit_size)
      if _wall_exists(grid_x_coords, grid_y_coords):
        return Vector2(horizontal_x_intersection, horizontal_y_intersection)
      if horizontal_y_intersection < 0 or horizontal_y_intersection > screensize.y \
        or horizontal_x_intersection < 0 or horizontal_x_intersection > screensize.x:
          break

func _wall_exists(x, y):
  return map_representation.has([x, y])

func _find_first_Y_h_intersection(ray_degree, player_position, is_facing_down):
  if is_facing_down:
    return (floor(player_position.y / grid_unit_size) * grid_unit_size + grid_unit_size)
  else:
    return ((floor(player_position.y / grid_unit_size) * grid_unit_size) - 1)

func _find_first_X_h_intersection(ray_degree, player_position, horizontal_y_intersection):
  return floor(player_position.x - ((player_position.y - horizontal_y_intersection) / f_tan_table[ray_degree]))

func _find_next_Y_h_intersection(is_facing_down):
  return grid_unit_size if is_facing_down else -grid_unit_size

func _find_next_X_h_intersection(ray_degree):
  return f_x_step_table[ray_degree]

func _check_vertical_intersections(player_position, ray_degree):
  var i = 0
  var is_facing_left = (ray_degree > ANGLE90 and ray_degree < ANGLE270)
  var vertical_x_intersection
  var vertical_y_intersection

  while (true):
    if i == 0:
      vertical_x_intersection = _find_first_X_v_intersection(ray_degree, player_position, is_facing_left)
      vertical_y_intersection = _find_first_Y_v_intersection(ray_degree, player_position, vertical_x_intersection)
      var grid_x_coords = int(vertical_x_intersection / grid_unit_size)
      var grid_y_coords = int(vertical_y_intersection / grid_unit_size)
      i += 1
      if _wall_exists(grid_x_coords, grid_y_coords):
        return Vector2(vertical_x_intersection, vertical_y_intersection)
    else:
      vertical_x_intersection += _find_next_X_v_intersection(is_facing_left)
      vertical_y_intersection -= _find_next_Y_v_intersection(ray_degree)
      var grid_x_coords = int(vertical_x_intersection / grid_unit_size)
      var grid_y_coords = int(vertical_y_intersection / grid_unit_size)
      if _wall_exists(grid_x_coords, grid_y_coords):
        return Vector2(vertical_x_intersection, vertical_y_intersection)
      if vertical_y_intersection < 0 or vertical_y_intersection > screensize.y \
        or vertical_x_intersection < 0 or vertical_x_intersection > screensize.x:
          break

func _find_first_X_v_intersection(ray_degree, player_position, is_facing_left):
  if is_facing_left:
    return (floor(player_position.x / grid_unit_size) * grid_unit_size - 1)
  else:
    return ((floor(player_position.x / grid_unit_size) * grid_unit_size) + grid_unit_size)

func _find_first_Y_v_intersection(ray_degree, player_position, vertical_x_intersection):
  return floor(player_position.y - ((player_position.x - vertical_x_intersection) * f_tan_table[ray_degree]))

func _find_next_X_v_intersection(is_facing_left):
  return -grid_unit_size if is_facing_left else grid_unit_size

func _find_next_Y_v_intersection(ray_degree):
  return f_y_step_table[ray_degree]