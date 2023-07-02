extends KinematicBody2D

enum states {
	IDLE = 0,
	RUNNING = 1,
	SLIDING = 2,
}

var aiming = false
export(float) var current_speed
export(float) var shooting_mode_delay
var shoot_mode = false
export(float) var shoot_mode_decreasing_multiplier 
var shoot_mode_current_decreasing_multiplier = shoot_mode_decreasing_multiplier

export(float) var hp 
export(float) var max_hp 

var lvl = 1
var xp = 0
var lvl_xp = [300, 700, 1200, 2000] #1-st element stands for xp need to get 2 lvl

#slide vars
export(float) var slide_cooldown #slide cooldown AFTER end of sliding 
var slide_velocity_multiplier = 1 #do not change
var aiming_speed_multiplier = 1 #do not change
var time_after_slide = 0
export(float) var slide_time 
export(float) var slide_min_speed_multiplier
export(float) var slide_max_speed_multiplier

var ammo = 5
var max_ammo = 200
var facing_direction	
var state

signal hp_changed	


"""func set_speed(var _speed):
	speed = _speed"""

func gain_ammo(var _ammo):
	ammo += _ammo
	if _ammo > 0 and get_node("/root/world/UI/reloading/animation").assigned_animation == "NoAmmo":
		get_node("/root/world/UI/reloading/animation").play("Default")
		get_node("/root/world/UI/reloading").visible = false
	
func gain_xp(var _xp):
	xp += _xp
	while lvl != lvl_xp.size() + 1 and xp >= lvl_xp[lvl - 1]: 
		xp -= lvl_xp[lvl - 1]
		lvl += 1
	
func change_hp(var _hp):
	if _hp >= 0: 
		hp = min(hp + _hp, max_hp)
	elif _hp < 0:
		hp = max(hp + _hp, 0)
	emit_signal("hp_changed")
	get_node("hurt_cooldown").start(1)
	
func get_active_hand():
	return get_node("/root/world").player().get_node("gun_hand")
func get_inactive_hand():
	return get_node("/root/world").player().get_node("inactive_hand")
func get_active_weapon():
	return get_node("/root/world").player().find_node("weapon").get_child(0)
var velocity = Vector2.ZERO

func _ready():
	facing_direction = "right" if position.x < get_global_mouse_position().x else "left"
	connect("hp_changed", self, "hp_changed")
	get_node("shooting_mode").connect("timeout", self, "shoot_mode")
	state = states.IDLE
	$slide_cooldown.start(slide_cooldown)
	get_node("legs").add_to_group("player_legs")

func shoot_mode():
	shoot_mode = false
	shoot_mode_current_decreasing_multiplier = shoot_mode_decreasing_multiplier
	#print("1")

func hp_changed():
	#get_node("hurt_sound").play()
	print(name + " taked damage")
	update_hp()
	if hp <= 0:
		die()
	
func update_hp():
	var hp_bar = get_node("/root/world/UI/hp_bar")
	var hp_label = get_node("/root/world/UI/hp_bar/hp")
	hp_bar.value = float(hp) / float(max_hp) * 100
	hp_label.text = str(hp) + "/" + str(max_hp)

func try_reload() -> bool:
	var gun = get_active_weapon()
	if gun.is_reloading == false:
		if gun.get_node("reload").get_time_left() == 0:
			if gun.ammo_in_magazine	!= gun.max_ammo_in_magazine and ammo > 0:
				reload()
				return true
	return false

func try_fire() -> bool:
	var gun = get_active_weapon()
	if state != states.SLIDING and gun.get_node("attack_cooldown").get_time_left() == 0:
		if gun.ammo_in_magazine >= gun.ammo_for_shot and gun.is_reloading == false:
			fire()
			return true
	return false

func play_red_indicator():
	get_node("/root/world/UI/reloading/animation").play("NoAmmo")
	get_node("/root/world/UI/reloading").visible = true

func _process(delta):
	var gun = get_active_weapon()
	if Input.is_action_just_pressed("ui_key_F1"):
		get_node("/root/world/UI/dev_label").visible = !get_node("/root/world/UI/dev_label").visible
		gain_ammo(10)
	
	if Input.is_action_just_pressed("ui_key_R"):
		var b = try_reload()
		if b == false and gun.is_reloading == false and gun.ammo_in_magazine != gun.max_ammo_in_magazine:
			play_red_indicator()
			
	
	if Input.is_action_pressed("ui_key_shift") and velocity.length() != 0 and get_node("slide_cooldown").get_time_left() == 0:
		if state != states.SLIDING: 
			enter_slide()
	if Input.is_action_pressed("ui_mouse_right_click") and aiming == false and state != states.SLIDING:
		gun.get_node("spread_curve").interpolate_property(gun, "current_spread", gun.current_spread, gun.aiming_min_spread,
	0.3,Tween.TRANS_LINEAR , Tween.EASE_IN_OUT)
		gun.get_node("spread_curve").start()
		aiming = true	
		aiming_speed_multiplier = 0.6

	if !Input.is_action_pressed("ui_mouse_right_click") and aiming == true:
		aiming = false
		gun.get_node("spread_curve").interpolate_property(gun, "current_spread", gun.current_spread, gun.running_min_spread,
	0.3,Tween.TRANS_LINEAR , Tween.EASE_IN_OUT)
		gun.get_node("spread_curve").start()
		aiming_speed_multiplier = 1
		
	match state:
		states.IDLE:
			idle()
		states.SLIDING:
			sliding(delta)
		states.RUNNING:
			running()
	if state != states.SLIDING:
		process_movement()
	process_gun_flip()
	
	var collision = move_and_collide(velocity * slide_velocity_multiplier * aiming_speed_multiplier)
	if collision != null:
		if state == states.SLIDING:
			exit_slide()
		if collision.collider.is_in_group("enemies"):
			collision.collider.damage_melee(self)


func fff(anim):
	print("fff")	
	#if 
	get_node("/root/world/UI/reloading/animation").play("Default")
	get_node("/root/world/UI/reloading").visible = false
	get_node("/root/world/UI/reloading/animation").disconnect("animation_finished", self, "fff")
	
func reload():
	var gun = get_active_weapon()
	get_node("/root/world/UI/reloading/animation").play("Default")
	gun.get_node("reload").start(gun.reload_time)
	gun.get_node("reload").connect("timeout", self, "finish_reload")
	get_node("/root/world/UI/reloading").visible = true
	gun.is_reloading = true

func finish_reload():
	var gun = get_active_weapon()
	var need_ammo = gun.max_ammo_in_magazine - gun.ammo_in_magazine
	if ammo >= need_ammo:
		gun.ammo_in_magazine = gun.max_ammo_in_magazine
		ammo -= need_ammo
	elif ammo < need_ammo:
		gun.ammo_in_magazine += ammo
		ammo = 0
	get_active_weapon().is_reloading = false
	get_node("/root/world/UI/reloading").visible = false
	
func enter_slide():
	gain_xp(175)
	state = states.SLIDING
	aiming = false
	aiming_speed_multiplier = 1
	time_after_slide = 0
	velocity = velocity.normalized() * current_speed
	
	get_node("slide_speed_curve").interpolate_property(self, "slide_velocity_multiplier", slide_max_speed_multiplier, slide_min_speed_multiplier,
	slide_time, Tween.TRANS_EXPO, Tween.EASE_OUT) 
	"""
	line above set property to smoothly changes for an amount of time via some math functions; here EXPO_OUT is used, click link to see all
	possible transition types: https://easings.net/en
	"""
	get_node("slide_speed_curve").connect("tween_all_completed", self, "exit_slide")
	get_node("slide_speed_curve").start()
	
func exit_slide():
	state = states.IDLE
	get_node("slide_speed_curve").stop_all()
	slide_velocity_multiplier = 1
	get_node("slide_cooldown").start(slide_cooldown)

func die():
	print("now player have to die")
	set_process(false) 
	
func process_movement():
	var input_force = Vector2.ZERO
	input_force.x = (Input.get_action_strength("ui_key_D") - Input.get_action_strength("ui_key_A")) 
	input_force.y = (Input.get_action_strength("ui_key_S") - Input.get_action_strength("ui_key_W"))
	
	if input_force != Vector2.ZERO:
		velocity = input_force.normalized() * current_speed * slide_velocity_multiplier
		state = states.RUNNING
	else:   
		velocity *= 0.7
	if abs(velocity.x) <= 0.01:
		velocity.x = 0
	if abs(velocity.y) <= 0.01:
		velocity.y = 0	
	if velocity == Vector2(0, 0):
		state = states.IDLE
	
func idle():
	get_node("inactive_hand_animation").play("Idle")
	get_node("body_animation").play("Idle")
	
func running():	
	if aiming == false:
		if (facing_direction == "right" and velocity.x < 0) or (facing_direction == "left" and velocity.x > 0):
			get_node("body_animation").play("RunningBackwards") 
			get_node("inactive_hand_animation").play("RunningBackwards")
		elif (facing_direction == "right" and velocity.x >= 0) or (facing_direction == "left" and velocity.x <= 0):
			get_node("body_animation").play("Running")
			get_node("inactive_hand_animation").play("Running")
	elif aiming == true:
		if (facing_direction == "right" and velocity.x < 0) or (facing_direction == "left" and velocity.x > 0):
			get_node("body_animation").play("WalkingBackwards") 
			get_node("inactive_hand_animation").play("WalkingBackwards")
		elif (facing_direction == "right" and velocity.x >= 0) or (facing_direction == "left" and velocity.x <= 0):
			get_node("body_animation").play("Walking")
			get_node("inactive_hand_animation").play("Walking")
					
func sliding(delta):
	get_node("body_animation").play("Sliding")
	get_node("inactive_hand_animation").play("Sliding")
	time_after_slide += delta	
	var transition_length = get_node("body_animation").get_animation("SlidingTransition").get_length()
	
	if time_after_slide + transition_length >= slide_time or time_after_slide <= transition_length:
		get_node("body_animation").play("SlidingTransition")
		get_node("inactive_hand_animation").play("SlidingTransition")
		
	if time_after_slide >= slide_time:	
		exit_slide()
	
func degrees_to_sector(degrees):
	var c = cos(deg2rad(degrees))
	if c <= cos(deg2rad(240)) and c >= -1:
		return "left"
	elif c >= cos(deg2rad(300)) and c <= 1:
		return "right"
	elif c > cos(deg2rad(240)) and c < cos(deg2rad(300)):
		return "middle"
	
func process_gun_flip():
	var hand = get_active_hand()
	var gun = get_active_weapon()
	var cursor = get_global_mouse_position()
	var cursor_deadzone = hand.get_node("Area2D/CollisionShape2D")
	if (cursor - cursor_deadzone.global_position).length() <= cursor_deadzone.shape.radius == true:
		return 
	
	
	var point = gun.get_node("point")
	var point_1 = gun.get_node("point_1")
	var vect = Vector2(point_1.global_position.x - point.global_position.x, point_1.global_position.y - point.global_position.y)	
	
	var weapon_end = get_active_weapon().get_node("point_1").global_position
	var angle
	if facing_direction == "right":
		angle = rad2deg((cursor - weapon_end).angle())
	if facing_direction == "left":
		angle = rad2deg((weapon_end - cursor).angle() * -1)
	hand.rotation_degrees = angle

	var p = global_position
	var c = get_global_mouse_position()
	var degrees = rad2deg((c - p).angle())
	
	if degrees_to_sector(degrees) == "right": 
		facing_direction = "right"
		set_transform(Transform2D(Vector2(1, 0), Vector2(0, 1), position))
	elif degrees_to_sector(degrees) == "left": 
		facing_direction = "left"
		set_transform(Transform2D(Vector2(-1, 0), Vector2(0, 1), position))
		
func fire():
	shoot_mode = true
	shoot_mode_current_decreasing_multiplier = 1
	get_node("shooting_mode").start(shooting_mode_delay)
	var gun = get_active_weapon()
	gun.fire()
	gun.get_node("animation").stop() #maybe will be rewritten using 'if'
	gun.get_node("animation").play("Shooting")
	get_node("gun_hand_animation").stop() #maybe will be rewritten using 'if'
	get_node("gun_hand_animation").play("Shooting") 

