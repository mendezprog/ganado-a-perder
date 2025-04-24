extends Area2D

@export var speed: float = 200
@export var lifetime: float = 0.3

var velocity = Vector2.ZERO
var time_alive = 0.0

func _ready():
	time_alive = 0.0

func _process(delta):
	position += velocity * delta
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()
