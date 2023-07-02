extends Label

func _process(delta: float) -> void:
	var player = get_node("/root/world").player()
	var string = "\nPress F1 to hide"
	#string += "\nstate = " + str(player.state) + "\naiming = " + str(player.aiming) 
	string += "\n\ngun spread degrees: " + str(int(player.get_active_weapon().current_spread))
	string += "\nshooting mode = " + str(player.shoot_mode) 
	string += "\nammo_in_magazine = " + str(player.get_active_weapon().ammo_in_magazine)
	string += "\nammo = " + str(player.ammo)
	string += "\nis_reloading = " + str(player.get_active_weapon().is_reloading)
	string += "\ncurrent animation = " + str(get_node("/root/world/UI/reloading/animation").assigned_animation)
	string += "\nlvl = " + str(get_node("/root/world").player().lvl)
	string += "; xp = " + str(get_node("/root/world").player().xp)
	string += "\npause = " + str(get_tree().paused)
	text = string


