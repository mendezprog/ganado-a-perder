extends Node2D


func startGame():
	if Input.is_action_pressed("enter"):
		get_tree().change_scene_to_file("res://Scenes/cutscene.tscn")
func _process(delta: float) -> void:
	startGame()
