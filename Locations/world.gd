extends Node2D

const Apathy = preload("res://Characters/apathy.tscn")
const Pistol = preload("res://Weapons/Guns/pistol.tscn")
const Dummy = preload("res://Enemies/dummy.tscn")
const Cursor = preload("res://UI/cursor.tscn")
const UI = preload("res://UI/UI.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var character = Apathy.instance()
	get_node("/root/world/player").add_child(character)
	character.add_to_group("players")
	var dummy = Dummy.instance()
	get_node("/root/world").add_child(dummy)
	dummy.global_position += Vector2(50, 50)	
	dummy.add_to_group("enemies")
	
	var pist = Pistol.instance()
	player().get_node("gun_hand/weapon").add_child(pist)
	
	var ui = UI.instance()
	get_node("/root/world").add_child(ui)
	
	var cursor = Cursor.instance()
	get_node("/root/world/UI").add_child(cursor)

	if OS.get_power_percent_left() != -1:
		get_node("/root/world/UI/dev_label").visible = false #hide dev label on laptops
	
	print(Global.s)
	
func player():
	return get_tree().get_nodes_in_group("players")[0]

	
