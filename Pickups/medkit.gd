extends "res://Pickups/pickups.gd"

var heal_amount = 1

func _ready():
	pass

func on_pickup(area): #redefinition because medkit doesn't have to be pickable on max player health
	if area.is_in_group("player_legs") and area.owner.hp != area.owner.max_hp:
		print("picked up " + name)
		give_items(area.owner)
		queue_free()

func give_items(body):
	body.hp = min(body.max_hp, body.hp + heal_amount)
	print(body.hp)
	print(body.name)
	body.emit_signal("hp_changed")
	#print(str(min(body.max_hp, body.hp + heal_amount)))

