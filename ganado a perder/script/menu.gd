extends Node2D



func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/cutscene.tscn")

func _on_opciones_pressed() -> void:
	pass # Replace with function body.

func _on_salir_pressed() -> void:
	get_tree().quit()
