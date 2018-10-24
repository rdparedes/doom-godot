extends Control

const PROJECTION_PLANE_DISTANCE = 277
const FOV = 60

var screensize
var angle_between_rays

func _ready():
	screensize = get_viewport_rect().size
	angle_between_rays = FOV / screensize.x

func _draw():
	#for