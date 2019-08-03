tool
extends Spatial

export var columns = 5
export var cell_size = 10

func _ready():
	print("Distributing n children: ", get_child_count())
	for childIndex in range(get_child_count()):
		var child = get_child(childIndex)
		var x = floor(childIndex / 5)
		var z = childIndex % 5
		child.set_translation(Vector3(x * cell_size, 0, z * cell_size))