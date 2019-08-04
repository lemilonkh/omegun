extends GridMap

#________                                               ________                                   __                
#\______ \  __ __  ____    ____   ____  ____   ____    /  _____/  ____   ____   ________________ _/  |_  ___________ 
# |    |  \|  |  \/    \  / ___\_/ __ \/  _ \ /    \  /   \  ____/ __ \ /    \_/ __ \_  __ \__  \\   __\/  _ \_  __ \
# |    `   \  |  /   |  \/ /_/  >  ___(  <_> )   |  \ \    \_\  \  ___/|   |  \  ___/|  | \// __ \|  | (  <_> )  | \/
#/_______  /____/|___|  /\___  / \___  >____/|___|  /  \______  /\___  >___|  /\___  >__|  (____  /__|  \____/|__|   
#        \/           \//_____/      \/           \/          \/     \/     \/     \/           \/                   

export var width = 22
export var height = 22

func has_neighbor(x, y, z, cell_type = INVALID_CELL_ITEM):
	return (get_cell_item(x + 1, y, z) == cell_type or get_cell_item(x - 1, y, z) == cell_type or get_cell_item(x, y, z + 1) == cell_type	 or get_cell_item(x, y, z - 1) == cell_type or get_cell_item(x + 1, y, z + 1) == cell_type or get_cell_item(x +  1, y, z - 1) == cell_type or get_cell_item(x - 1, y, z + 1) == cell_type or get_cell_item(x  - 1, y, z - 1) == cell_type)

func randint(valmin, valmax):
	randomize()
	
	if valmin > valmax:
		valmin = valmin + valmax
		valmax = valmin - valmax
		valmin = valmin - valmax
	
	if valmin + valmax == 0:
		return randi() % (2 * valmax) + valmin
	
	if valmin < 0 and valmax < 0:
		return (randi() % (valmin + valmax ) + valmin) * -1
	
	return randi() % int(abs(valmax) - abs(valmin) ) + valmin

func swap(a, b):
	return([b, a])
	
func collision_test(x1a, z1a, x2a, z2a, x1b, z1b, x2b, z2b):
	var collisionX = 0
	var collisionZ = 0
	
	if x1a < x1b and x1b < x2a or x1a < x2b and x2b < x2a:
		collisionX = 1
	if z1a < z1b and z1b < z2a or z1a < z2b and z2b < z2a:
		collisionZ = 1
	if x1b < x1a and x1a < x2b or x1b < x2a and x2a < x2b:
		collisionX = 1
	if z1b < z1a and z1a < z2b or z1b < z2a and z2a < z2b:
		collisionZ = 1

	if x1a > x1b and x1b > x2a or x1a > x2b and x2b > x2a:
		collisionX = 1
	if z1a > z1b and z1b > z2a or z1a > z2b and z2b > z2a:
		collisionZ = 1
	if x1b > x1a and x1a > x2b or x1b > x2a and x2a > x2b:
		collisionX = 1
	if z1b > z1a and z1a > z2b or z1b > z2a and z2a > z2b:
		collisionZ = 1

	if collisionX and collisionZ:
		return 1
	else:
		return 0

func add_room(recursionlvl, list_of_rooms, room_id):
	if recursionlvl > 0 :
		for i in range(0, 2):
			var room_successfully_placed = false
			var remaining_try = 10
			while(not(room_successfully_placed)):
				var parent = list_of_rooms[room_id]
				randomize()
				width = randint(5, 20)
				height = randint(5, 20)
				
				var sideXorZ = randint(0, 2)
				var side1or2 = randint(0, 2)
				var originMain =  randint(parent[sideXorZ] + 1, parent[sideXorZ + 2] - 1)
				var originSecondary
				var originX
				var originY
				
				if sideXorZ == 1:
					originSecondary = parent[0 + 2 * side1or2]
					originX = originSecondary
					originY = originMain
				
				if sideXorZ == 0:
					originSecondary = parent[1 + 2 * side1or2]
					originX = originMain
					originY = originSecondary
				var room 
				if sideXorZ == 0 and side1or2 == 00:
					#bottom
					room = [originX - width/ 2, originY, originX + width / 2 , originY - height]
				elif sideXorZ == 0 and side1or2 == 1:
					#top
					room = [originX - width/ 2, originY, originX + width / 2 , originY + height]
				elif sideXorZ == 1 and side1or2 == 0:
					#left
					room = [originX, originY - height / 2, originX -  width, originY + height / 2]
				else:
					#right
					room = [originX, originY - height / 2, originX +  width, originY + height / 2]
					
				var collision = 0
				for i in range(list_of_rooms.size()):
					#print(room ,"   ,")
					collision += collision_test(room[0], room[1], room[2], room[3], list_of_rooms[i][0], list_of_rooms[i][1], list_of_rooms[i][2], list_of_rooms[i][3])
				if collision == 0:
					list_of_rooms.append(room)
					#print("debugroom", room, originX," ", originY," ", room_id, parent)
					print(room, ",")
					add_room(recursionlvl - 1, list_of_rooms, list_of_rooms.size() - 1)
					room_successfully_placed = true
				remaining_try -= 1
				if remaining_try == 0:
					#print("fail")
					room_successfully_placed = true

func _init():
	var frog = preload("res://scenes/enemies/frog.tscn") # TODO use this?
	var recursion = 8
	var room_size = 20
	
	# CONTAINS THE COORDINATES OF ALL ROOMS IN A FORMAT [[xmin, zmin, xmax, zmax],[...],[...],...]
	var list_of_rooms = [[-room_size,-room_size,room_size,room_size]]
	add_room(recursion , list_of_rooms, 0)
	var item = 1
	var y = 0

	# floors
	for i in range(list_of_rooms.size()):
		print(list_of_rooms[i])
		for x in range(list_of_rooms[i][0], list_of_rooms[i][2]):
			for z in range( list_of_rooms[i][1], list_of_rooms[i][3]):
				set_cell_item(x, y, z, item, 0)
				
				if y > 0:
					set_cell_item(x, 0, z, 1, 0)
	
	# walls
	for i in range(list_of_rooms.size()):
		for x in range(list_of_rooms[i][0], list_of_rooms[i][2]):
			for z in range( list_of_rooms[i][1], list_of_rooms[i][3]):
				if has_neighbor(x, y, z):
					set_cell_item(x, y + 1, z, 1)
