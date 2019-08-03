extends Node

static func set_global_position(node, position):
	node.set_global_transform(Transform(node.get_global_transform().basis, position))

static func short_angle_dist(a0, a1):
	var da  = fmod(a1 - a0, 2 * PI)
	return fmod(2 * da, 2 * PI) - da

static func lerp_angle(a0, a1, t):
	return a0 + short_angle_dist(a0, a1) * t