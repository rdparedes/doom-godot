extends CanvasLayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func update_player_angle(angle):
	$Angle/Value.text = str(angle)

func update_player_position(position):
	$Position/Value.text = str(position.x, ", ", position.y)