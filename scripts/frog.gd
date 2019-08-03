extends Spatial

export var speed = 1
var animation
var jump_animation = "Frog_Jump-loop"

func _ready():
	animation = get_node("AnimationPlayer")
	animation.play(jump_animation)
	
func _process(delta):
	translate(transform.basis.x * speed * delta)
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	print("finished: " + anim_name)
	if anim_name == jump_animation:
		animation.play(jump_animation)
		rotate(transform.basis.y, PI)
