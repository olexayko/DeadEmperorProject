extends "res://Enemies/enemy.gd"

var received_damage = 0

func damage(var dmg):
	received_damage += dmg
	get_node("damage_received").text = "" + str(received_damage)


