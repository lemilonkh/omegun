extends GridMap

var size = 5

func _ready():
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8
	
	var meshCount = self.mesh_library.get_item_list().size()
	
	for x in range(-size, size):
		for z in range(-size, size):
			var height = noise.get_noise_2d(x, z) * size
			
			for y in range(-size, height):
				var itemNoise = (noise.get_noise_3d(x, y, z) + 1) / 2 # normalize range to [0,1]
				var item = floor(itemNoise * meshCount)
				set_cell_item(x, y, z, item, 0)
