extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	$Player.position = $StartPosition.position

func _process(delta):
	$Debug.update_player_angle($Player.get_angle())
	$Debug.update_player_position($Player.get_position_as_int())
