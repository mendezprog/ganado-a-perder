extends Area2D

var speed := 500
var raycast_length := 10.0

func _ready() -> void:
	set_as_top_level(true)

func bulletEnteredMartin():
	queue_free()

func _process(delta: float) -> void:
	var direction = (Vector2.RIGHT * speed).rotated(rotation).normalized()
	position += direction * speed * delta
	_check_foreground_collision(direction)

func _check_foreground_collision(direction: Vector2):
	var space_state = get_world_2d().direct_space_state
	var from = global_position
	var to = from + direction * raycast_length

	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 1  # Asegúrate que el TileMapLayer de foreground tenga esta máscara

	var result = space_state.intersect_ray(query)
	if result and result.collider and result.collider.name == "foreground":
		queue_free()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
