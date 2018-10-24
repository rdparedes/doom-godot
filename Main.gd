extends Node

func _ready():
	$Player.position = $StartPosition.position

func _process(delta):
	$Debug.update_player_angle($Player.get_rotation())
	$Debug.update_player_position($Player.get_position_as_int())
	$Projection.cast_rays($Player)
	$Debug.update_ray($Projection.aY, $Projection.aX)
