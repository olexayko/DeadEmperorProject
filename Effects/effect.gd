extends Node2D

func _ready():
	var animation = get_node("animation")
	animation.play("Shooting")
	animation.connect("animation_finished", self, "die")

func die(name):
	queue_free()
	print("called die")
	
