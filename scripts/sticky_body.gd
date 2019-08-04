extends PhysicsBody

var attached = false

func is_attached():
	return attached

func attach():
	attached = true

func _ready():
	if not is_in_group("sticky"):
		add_to_group("sticky")
