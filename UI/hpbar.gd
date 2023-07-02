extends TextureProgress

func _ready():
	var player = get_node("/root/world").player()
	player.update_hp()
