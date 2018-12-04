extends Node2D

var x = 0
var y = 0

func _ready():
  pass

func _draw():
  draw_circle(Vector2(x, y), 1, Color('#00FF00'))
