extends Spatial

var start_position
var distance = 3
var time = 0

func _init():
	start_position = get_translation()

func _process(delta):
	time += delta
	set_translation(start_position + Vector3(0, 0, distance * sin(time)))