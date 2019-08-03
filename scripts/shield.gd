extends Spatial

const FADE_DURATION = 0.5

onready var plane = get_node("Plane")
onready var timer = get_node("timer")
onready var tween = get_node("tween")

var material
var starting_alpha

func _ready():
	material = plane.get_surface_material(0)
	starting_alpha = material.get_shader_param("alpha")
	plane.set_visible(false)

func show():
	plane.set_visible(true)
	tween.interpolate_property(material, "shader_param/alpha", 0, starting_alpha, FADE_DURATION, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	timer.start()

func _on_timeout():
	tween.interpolate_property(material, "shader_param/alpha", starting_alpha, 0, FADE_DURATION, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()