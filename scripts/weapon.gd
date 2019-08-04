extends RigidBody

export(float, 0, 1) var damage = 1
export(float, 0, 100) var max_damage_force = 1 # Newton

var is_attached = false
var force = Vector3()

func _ready():
	pass

func take_damage(damage, source):
	pass

func attack():
	pass

func get_damage():
	var force_scale = clamp(force.length() / max_damage_force, 0, 1)
	return force_scale * damage

func _on_body_entered(body: PhysicsBody):
	print("Body entered", body)
	var damage = get_damage()
	
	if body.has_method("take_damage"):
		print("Body taking damage: ", damage)
		body.take_damage(damage, self)

func _on_body_exited(body):
	pass

func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	pass

func _on_mouse_entered():
	pass

func _on_mouse_exited():
	pass
