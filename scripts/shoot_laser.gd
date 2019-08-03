extends MeshInstance

export(NodePath) var target_node
var target
var laser

func _ready():
	target = get_node(target_node)
	laser = $laser

func _process(delta):
	var position = get_global_transform().origin
	var target_position = target.get_global_transform().origin
	
	var direction = target_position - position
	var distance = 2 * direction.length()
	direction = direction.normalized()
	
	laser.look_at(target_position, Vector3(0, 1, 0))
	laser.set_scale(Vector3(1, distance, 1))
