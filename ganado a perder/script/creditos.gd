extends Node2D

func goBack():
	if Input.is_action_pressed("back"):
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
		
func _process(delta: float) -> void:
	goBack()
