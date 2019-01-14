extends Control

const NO_INTERSECTION = { "x": -1, "y": -1 }

func update_player_angle(angle):
  $Angle/Value.text = str(angle)

func update_player_position(position):
  $Position/Value.text = str(position.x, ", ", position.y)

func update_ray(first_r, last_r):
  if first_r:
    $FirstRay.position = first_r
  if last_r:
    $LastRay.position = last_r
  $FirstRay.update()
  $LastRay.update()
