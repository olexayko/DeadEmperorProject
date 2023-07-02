extends TextureProgress

func _ready() -> void:
	#var over_tex = preload("res://Sprites/UI/bulet_indicator_empty_2.png")
	#set_over_texture(over_tex)
	pass
	
func _process(delta: float) -> void:
	var gun = get_node("/root/world").player().get_active_weapon()
	
	if gun.is_reloading:
		value = 105 - gun.get_node("reload").get_time_left() / gun.reload_time * 100
		#print(value)


