extends Label

func _process(delta: float) -> void:
	var player = get_node("/root/world").player()
	text = str(player.lvl)

