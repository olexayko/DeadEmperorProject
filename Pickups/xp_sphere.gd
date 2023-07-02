extends "res://Pickups/pickups.gd"

var xp_amount = 30
#export(Array, PackedScene) var lootpool
#var current_speed = 0
var speed = 3
var is_following_player = false

func additional_ready():
	get_node("magnet_area").connect("body_entered", self, "turn_on_following")
	pass

func turn_on_following(body):
	if body.is_in_group("players"):
		is_following_player = true
	
func give_items(body):
	body.gain_xp(xp_amount)

func _process(delta: float) -> void:
	if is_following_player:
		var player_legs = get_node("/root/world").player().get_node("legs")
		global_position = global_position.move_toward(player_legs.global_position, speed)

func change_pause_mode():
	get_tree().paused = !get_tree().paused
