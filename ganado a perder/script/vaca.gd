extends CharacterBody2D


const SPEED = 100.0


func _physics_process(delta: float) -> void:


	move_and_slide()
