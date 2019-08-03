extends GridMap

export var width = 22
export var height = 22

func _init():
	set_translation(Vector3(-width / 2, 0, -height / 2))
	
	for x in range(0, width):
		for z in range(0, height):
			var y = 0
			var item = 1
			
			if x == 0 || x == width-1 || z == 0 || z == height - 1:
				y = 1
				item = 0
			
			if x % 4 == 1 && z % 4 == 1 && randi() % 4 != 0:
				y = 1
				item = 0
			
			# make sure there's always ground below all walls
			if y > 0:
				set_cell_item(x, 0, z, 1, 0)
			
			set_cell_item(x, y, z, item, 0)