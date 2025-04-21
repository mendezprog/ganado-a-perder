extends Area2D

@export var speed := 400.0
@export var direction := Vector2.RIGHT
@export var lifetime := 2.0

func _ready():
	# Autodestruir tras unos segundos
	await get_tree().create_timer(lifetime).timeout
	rotation = direction.angle()
	queue_free()

func _process(delta):
	position += direction.normalized() * speed * delta
