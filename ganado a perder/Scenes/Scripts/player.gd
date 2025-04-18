extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(581, 328)
	rotation = 0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for action in ["right", "left", "up", "down"]:
		if Input.is_action_pressed(action):
			match action:
				"right":
					$Ship.rotation_degrees = 180
					position += Vector2(20, 0) * 50 * delta
				"left":
					$Ship.rotation_degrees = 0
					position += Vector2(-20, 0) * 50 * delta
				"up":
					$Ship.rotation_degrees = 90
					position += Vector2(0, -20) * 50 * delta
				"down":
					$Ship.rotation_degrees = -90
					position += Vector2(0, 20) * 50 * delta
			break  # Prevent multiple movements if more than one key is pressed
	pass	
