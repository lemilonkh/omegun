extends Spatial

const FADE_DURATION = 0.5

var geometry_utils = preload("res://scripts/geometry_utils.gd")
onready var mesh = get_node("mesh")
onready var raycast = get_node("RayCast")
onready var particles = get_node("Particles")
onready var animation = get_node("AnimationPlayer")
onready var timer = get_node("Timer")

var max_distance
var material
var color
var hidden_color

func _ready():
	max_distance = raycast.cast_to.length()
	material = mesh.get_surface_material(0)
	set_visible(false)
	set_process(false)
	color = material.albedo_color
	hidden_color = color
	hidden_color.a = 0

func show():
	animation.play("fade_in")
	timer.start()
	raycast.set_enabled(true)
	set_process(true)
	set_visible(true)

func _on_timeout():
	animation.play("fade_out")
	set_process(false)
	raycast.set_enabled(false)

func _process(delta):
	var distance = max_distance
	
	if raycast.get_collider() != null:
		var target_point = raycast.get_collision_point()
		var position = get_global_transform().origin
		distance = (target_point - position).length()
		particles.set_emitting(true)
		geometry_utils.set_global_position(particles, target_point)
	else:
		particles.set_emitting(false)
	
	mesh.set_scale(Vector3(distance, 1, 1))
	mesh.set_translation(Vector3(distance / 2, 0, 0))