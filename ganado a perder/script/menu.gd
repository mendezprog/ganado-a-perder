extends Node2D


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")

func _on_opciones_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/creditos.tscn")

func _on_salir_pressed() -> void:
	get_tree().quit()
