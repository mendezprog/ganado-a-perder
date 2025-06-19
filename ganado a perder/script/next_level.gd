extends Area2D

@export var level: PackedScene

func _on_body_entered(body: Node2D) -> void:
	print("Entró:", body.name)
	if body.name == "vaca":
		call_deferred("change_level")

func change_level():
	get_tree().change_scene_to_packed(level)
