extends Node2D

var x = 0
var y = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _draw():
	draw_circle(Vector2(x, y), 2, Color('#dadada'))
