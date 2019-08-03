extends KinematicBody

export var speed = 8

const destructible_group = "destructible"

func _ready():
	pass

func _process(delta):
	var direction = get_transform().basis[0]
	var collision = move_and_collide(speed * delta * direction)
	
	if collision != null:
		var collider = collision.collider
		if collider.get_groups().has(destructible_group):
			collider.queue_free()
		
		queue_free()
