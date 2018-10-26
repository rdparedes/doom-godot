extends Node

func _ready():
	$Player.position = $StartPosition.position
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
	$Projection.cast_rays($Player)

func _process(delta):
	$Debug.update_player_angle($Player.get_rotation())
	$Debug.update_player_position($Player.get_position_as_int())
	$Debug.update_ray($Projection.x_intersection, $Projection.y_intersection)
