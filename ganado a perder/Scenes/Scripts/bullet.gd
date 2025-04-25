extends Area2D

@export var speed: float = 200
@export var lifetime: float = 0.3
@export var is_friendly: bool = true  # 🚩 Nuevo

var velocity = Vector2.ZERO
var time_alive = 0.0

func _ready():
	time_alive = 0.0

func _process(delta):
	position += velocity * delta
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_area_entered(area: Area2D):
	if is_friendly and area.name == "Enemy":
		queue_free()
	elif not is_friendly and area.name == "Player":
		queue_free()
