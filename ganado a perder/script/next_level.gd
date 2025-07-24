extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("Entró:", body.name)
	if body.name == "vaca":
		call_deferred("change_level")

func change_level():
	GlobalStats.current_level += 1
	get_tree().change_scene_to_file("res://Scenes/upgrade_screen.tscn")
