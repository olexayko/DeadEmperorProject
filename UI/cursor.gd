extends Node2D

export(float) var pixels_in_spread = 5

var part_1_n = Vector2(1, -1)
var part_2_n = Vector2(1, 1)
var part_3_n = Vector2(-1, 1)
var part_4_n = Vector2(-1, -1)

func _process(delta):
	global_position = get_global_mouse_position()
	var gun = get_node("/root/world").player().get_active_weapon()
	var pixels = float(gun.current_spread) / float(pixels_in_spread)
	get_node("part_1").position = part_1_n * pixels
	get_node("part_2").position = part_2_n * pixels
	get_node("part_3").position = part_3_n * pixels
	get_node("part_4").position = part_4_n * pixels

