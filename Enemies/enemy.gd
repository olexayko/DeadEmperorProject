extends Node

var hp = 20
var damage = 1

func _ready():
	#get_node("area").connect("body_entered", self, "damage_melee")
	add_to_group("enemies")
	pass

func damage(var dmg):
	hp -= dmg
	get_node("/root/world/enemy_hp").text = str(hp)
	if hp <= 0:
		die()
	
func damage_melee(var body):
	print("called melee")
	if body.is_in_group("players"):
		if body.get_node("hurt_cooldown").get_time_left() == 0:
			print("damaged")
			body.hp -= damage
			body.emit_signal("hp_changed")
			body.get_node("hurt_cooldown").start(1)

func die():
	queue_free()

