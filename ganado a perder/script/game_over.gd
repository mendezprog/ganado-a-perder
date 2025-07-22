extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	restart()

func restart():
	await get_tree().create_timer(6).timeout
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
