extends Camera2D

@export var background: TileMapLayer

func _ready() -> void:
	# Asegurar que la cámara está activa
	make_current()

	# Obtener el área usada del tilemap
	var used_rect := background.get_used_rect()
	var tile_size := background.tile_set.tile_size

	# Calcular los límites en píxeles
	var world_position := used_rect.position * tile_size
	var world_size := used_rect.size * tile_size

	# Aplicar límites a la cámara
	limit_left = world_position.x
	limit_top = world_position.y
	limit_right = world_position.x + world_size.x
	limit_bottom = world_position.y + world_size.y
