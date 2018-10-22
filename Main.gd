extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	$Debug.update_player_angle($Player.get_angle())
	$Debug.update_player_position($Player.position)
