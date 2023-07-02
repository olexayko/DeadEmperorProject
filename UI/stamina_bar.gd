extends TextureProgress

func _ready():
	var player = get_node("/root/world").player()
	#value = float(player.stamina) / player.max_stamina * 100
	#get_node("stamina").text = str(player.stamina)
	
func _process(delta):
	var player = get_node("/root/world").player()
	#value = float(player.stamina) / player.max_stamina * 100
	#get_node("stamina").text = str(player.stamina)
