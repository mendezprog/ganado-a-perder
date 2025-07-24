extends Node2D

@onready var video_stream_player: VideoStreamPlayer = $Control/VideoStreamPlayer


func _ready() -> void:
	$AnimatedSprite2D.play("default")

func goBack():
	if Input.is_action_pressed("back"):
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
		
func _process(delta: float) -> void:
	goBack()


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
