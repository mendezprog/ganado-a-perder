extends Node2D


# Called when the node enters the scene tree for the first time.
func startGame():
	if Input.is_action_pressed("enter"):
		get_tree().change_scene_to_file("res://Niveles/lvl1.tscn")
func _process(delta: float) -> void:
	startGame()
