extends Camera

export var distance = -1.0
export var height = 5.0

func _init():
	set_as_toplevel(true)

func _process(delta):
	var position = get_global_transform().origin
	var target = get_parent().get_global_transform().origin
	var up = Vector3(0, 0, 1)
	
	var offset = Vector3(0, height, distance)
	
	#var offset = position - target
	#offset = offset.normalized() * distance
	#offset.y = height
	
	position = target + offset
	
	look_at_from_position(position, target, up)