extends KinematicBody

export var gravity = -9.8
export(NodePath) var camera_node
export var speed = 15
export var acceleration = 4
export var deceleration = 8

var geometry_utils = preload("res://scripts/geometry_utils.gd")

onready var bullet = preload("res:///scenes/bullet.tscn").instance()
onready var camera = get_node(camera_node)
onready var animation = get_node("AnimationPlayer")
onready var head = get_node("head_bone")
onready var shield = get_node("shield")
onready var laser = get_node("head_bone/laser")
onready var cards = get_node("cards")
onready var weapon = get_node("head_bone/weapon/scythe")

var velocity = Vector3()
var aim_angle = 0

func _ready():
	animation.play("reload")

func _physics_process(delta):
	var transform = camera.get_transform()
	var direction = Vector3()

	if Input.is_action_pressed("forward"):
		direction += transform.basis[1]
	if Input.is_action_pressed("backward"):
		direction -= transform.basis[1]
	if Input.is_action_pressed("left"):
		direction -= transform.basis[0]
	if Input.is_action_pressed("right"):
		direction += transform.basis[0]
	
	# charge/ perform attack
	if Input.is_action_pressed("attack"):
		laser.show()
	elif Input.is_action_just_released("attack"):
		shield.show()

	direction.y = 0
	direction = direction.normalized()

	velocity.y += delta * gravity
	var horizontal_velocity = velocity #.clone()
	horizontal_velocity.y = 0

	var movement = direction * speed
	var current_acceleration = deceleration

	if(direction.dot(horizontal_velocity) > 0):
		current_acceleration = acceleration
	
	horizontal_velocity = horizontal_velocity.linear_interpolate(movement, current_acceleration * delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
	# directional mouse aiming
	var mouse_position = get_viewport().get_mouse_position()
	var player_position = get_transform().origin
	var screen_position = camera.unproject_position(player_position)
	
	var aim_direction = screen_position - mouse_position
	aim_angle = aim_direction.angle_to(Vector2(1, 0))
	
	head.set_rotation(Vector3(0, aim_angle, 0))
	
	# fix shield performing 360 degree rotation when crossing over 0 angle (x axis)
	var shield_angle = geometry_utils.lerp_angle(shield.get_rotation().y, aim_angle, delta * 3)
	shield.set_rotation(Vector3(0, shield_angle, 0))

func take_damage():
	animation.play("damage")

func teleport():
	var direction = Vector3(1, 0, 0).rotated(Vector3(0, 1, 0), aim_angle)
	var distance = 10
	
	move_and_collide(direction * distance)

func _input(event):
	if event.is_action_pressed("attack"):
		#var bullet_instance = bullet.duplicate()
		#bullet_instance.set_rotation(Vector3(0, aim_angle, 0))
		#bullet_instance.set_translation(get_translation() - Vector3(0, 0.5, 0))
		#get_tree().get_root().add_child(bullet_instance)
		animation.play("shoot")
		weapon.attack()
	
	if event.is_action_pressed("reload"):
		animation.play("reload")

func _on_animation_finished(anim_name):
	if anim_name != "idle":
		animation.play("idle")
