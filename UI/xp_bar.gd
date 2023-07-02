extends TextureProgress

func _process(delta: float) -> void:
	var player = get_node("/root/world").player()
	if player.lvl != player.lvl_xp.size() + 1:
		value = float(player.xp) / player.lvl_xp[player.lvl - 1]  * 100
	else:
		value = 0

