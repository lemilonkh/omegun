extends RigidBody

export(float, 0, 1) var damage = 1
export(float, 0, 100) var max_damage_force = 1 # Newton

onready var model = $MeshInstance
onready var light = $OmniLight
onready var animation = $AnimationPlayer

var is_attached = false
var force = Vector3()

func _ready():
	print("Surface materials", model.get_surface_material_count())
	
	for material_id in range(model.get_surface_material_count()):
		var material: SpatialMaterial = model.get_surface_material(material_id)
		
		if material == null:
			continue
		
		var previous_color = material.albedo_color
		var new_color = Color(1, 0, 0, 1)
		material.set_albedo_color(new_color)

func take_damage(damage, source):
	pass

func attack():
	animation.play("attack")

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
	light.light_energy = 5

func _on_mouse_exited():
	light.light_energy = 0

func _on_animation_finished(anim_name):
	if anim_name == "attack":
		animation.play("idle")
