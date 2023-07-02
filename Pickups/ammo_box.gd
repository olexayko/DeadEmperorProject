extends "res://Pickups/pickups.gd"

var ammo_amount = 20

func _ready():
	pass

func give_items(body):
	body.gain_ammo(ammo_amount)
	pass
