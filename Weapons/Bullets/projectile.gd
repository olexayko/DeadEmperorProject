extends RigidBody2D

var damage setget set_damage
var speed setget set_speed

func set_damage(var _damage):
	damage = _damage

func set_speed(var _speed):
	linear_velocity = Vector2(linear_velocity.x * _speed, linear_velocity.y * _speed)
	speed = _speed

func _ready():
	contact_monitor = true
	contacts_reported = 10
	#connect("body_entered", self, "contact")
	get_node("area").connect("area_entered", self, "contact_area")
	connect("body_entered", self, "contact_body")
	#get_node("area").connect("body_entered", self, "contact_body")
	
func contact_area(var area):
	if area.name == "hurtbox":
		if area.owner.is_in_group("players"):
			if area.owner.get_node("hurt_cooldown").get_time_left() == 0:
				area.owner.change_hp(-damage)
			queue_free()
		
		elif area.owner.is_in_group("enemies"):
			area.owner.damage(damage)
			queue_free()
			print("1")

func contact_body(var body):
	if !body.is_in_group("players") and !body.is_in_group("enemies"):
		queue_free()

