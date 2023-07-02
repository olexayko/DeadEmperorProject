extends Node2D

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_pause"):
		get_tree().paused = !get_tree().paused
