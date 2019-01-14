extends Node2D


func _ready():
  $Projection.player.position = $StartPosition.position
  var map_representation = []
  for n in $HUD/Obstacles.get_children():
    map_representation.append(
      [
        int(n.position.x / $Projection.grid_unit_size),
        int(n.position.y / $Projection.grid_unit_size)
      ]
    )
  $Projection.map_representation = map_representation

func _process(delta):
  if Input.is_action_just_pressed('ui_show_hide_hud'):
    $HUD.show() if $HUD.visible == false else $HUD.hide()

  if $HUD.visible == true:
    $Debug.update_player_angle($HUD/Player.rotation_degrees)
    $Debug.update_player_position($Projection.player.position)
    $Debug.update_ray($Projection.debug_first_ray, $Projection.debug_last_ray)
