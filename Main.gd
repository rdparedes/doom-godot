extends Node

var PROJECTION_TO_360_RATIO

func _ready():
	$Projection.player.position = $StartPosition.position
	PROJECTION_TO_360_RATIO = floor($Projection.ANGLE360 / 360)
	var map_representation = []
	for n in $Obstacles.get_children():
		map_representation.append(
			[
				int(n.position.x / $Projection.grid_unit_size),
				int(n.position.y / $Projection.grid_unit_size)
			]
		)
	$Projection.map_representation = map_representation

func _physics_process(delta):
	$Projection.update()
	$Player.position = $Projection.player.position
	$Player.global_rotation_degrees = floor($Projection.player.rotation / PROJECTION_TO_360_RATIO)

func _process(delta):
	$Debug.update_player_angle($Projection.player.rotation)
	$Debug.update_player_position($Projection.player.position)
	$Debug.update_ray($Projection.debug_intersection)
