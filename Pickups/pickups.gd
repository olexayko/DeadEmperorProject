extends Node2D

func _ready() -> void:
	get_node("area").connect("area_entered", self, "on_pickup")
	additional_ready()
	pass
	
func additional_ready():
	pass
	
func on_pickup(area):
	if area.is_in_group("player_legs"):
		print("picked up " + name)
		give_items(area.owner)
		queue_free()
	
func give_items(body):
	pass

