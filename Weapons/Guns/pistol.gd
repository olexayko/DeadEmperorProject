extends "res://Weapons/Guns/gun.gd"

func _ready():
	get_node("attack_cooldown").start(shoot_delay)
	projectile_tscn_instance_path = "res://Weapons/Bullets/bullet.tscn"

func _input(event: InputEvent) -> void:
	var player = get_node("/root/world").player()
	if Input.is_action_just_pressed("ui_mouse_left_click"):
		var s = player.try_fire()
		if !s:
			if ammo_in_magazine < ammo_for_shot and is_reloading == false:
				var b = player.try_reload()
				if b == false and is_reloading == false:
					player.play_red_indicator()
	
