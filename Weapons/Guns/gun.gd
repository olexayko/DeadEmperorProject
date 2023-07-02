extends Node2D

var projectile_tscn_instance_path
export(float) var shoot_delay

#spread vars
var current_spread = 0

export(int) var ammo_in_magazine
export(int) var max_ammo_in_magazine
export(float) var reload_time 
export(int) var ammo_for_shot

var is_reloading = false

export(float) var aiming_min_spread
export(float) var aiming_max_spread
export(float) var aiming_spread_increment #per one SHOT
export(float) var aiming_spread_decrement #per one FRAME

export(float) var running_min_spread
export(float) var running_max_spread
export(float) var running_spread_increment #per one SHOT
export(float) var running_spread_decrement #per one FRAME

func _ready():
	get_node("/root/world").player().process_gun_flip()	

func apply_effect():
	var Effect = load("res://Effects/shooting_effect.tscn") 
	var effect = Effect.instance()
	effect.position = get_node("point").position
	var random = rand_range(0, 100)
	if(random > 50):
		effect.scale.y = -1
	get_node("/root/world").player().get_active_weapon().add_child(effect)

func fire():
	get_node("/root/world/UI/cursor/animation").stop(true)
	get_node("/root/world/UI/cursor/animation").play("Shooting")
	ammo_in_magazine -= ammo_for_shot
	var player = get_tree().get_nodes_in_group("players")[0]
	var Bullet = load(projectile_tscn_instance_path) 
	#TODO: somehow convert load() to preload() if possible
	var bullet = Bullet.instance()
	bullet.position = get_node("projectile_spawn_point").rect_global_position
	var i = 0
	while i < get_node("/root/world/player_projectiles").get_child_count():
		bullet.add_collision_exception_with(get_node("/root/world/player_projectiles").get_child(i))
		#bullet.add_collision_exception_with(player)
		i += 1
	var cursor = get_global_mouse_position()	
	var pos = get_node("/root/world").player().get_active_weapon().get_node("projectile_spawn_point").rect_global_position
	bullet.gravity_scale = 0
	bullet.linear_damp = 0
	bullet.contact_monitor = true
	bullet.bounce = false	
	var velocity = Vector2.ZERO
	var point_0 = get_node("projectile_spawn_point").rect_global_position
	var point_1 = get_node("point").global_position
	
	var deviation = rand_range(-current_spread, current_spread)
	bullet.linear_velocity = Vector2(point_0 - point_1).normalized().rotated(deg2rad(deviation)) 
	get_node("/root/world/player_projectiles").add_child(bullet)
	bullet.add_to_group("player_projectiles")
	get_node("attack_cooldown").start(shoot_delay) 
	get_node("/root/world").player().get_active_weapon().get_node("shot").play()
	apply_effect()
	if player.aiming == true:
		current_spread = min(current_spread + aiming_spread_increment, aiming_max_spread)
	elif player.aiming == false:
		current_spread = min(current_spread + running_spread_increment, running_max_spread)
	
func _process(delta: float) -> void:
	var player = get_node("/root/world").player()
	if !get_node("spread_curve").is_active():
		if player.aiming == true:
			current_spread = max(current_spread - aiming_spread_decrement * player.shoot_mode_current_decreasing_multiplier, aiming_min_spread)
		elif player.aiming == false:
			current_spread = max(current_spread - running_spread_decrement * player.shoot_mode_current_decreasing_multiplier, running_min_spread)
	else:
		pass
