extends CharacterBody2D

@export var speed := 100.0
@export var stop_distance := 64.0 # distancia mínima para dejar de seguir
@export var smoothing := 5.0 # entre mayor, más suave (y más delay)

var player: Node2D

func _ready():
	# Obtener jugador automáticamente desde grupo (opcional)
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	if not player:
		return

	var to_player = player.global_position - global_position
	var distance = to_player.length()

	if distance > stop_distance:
		# Movimiento suavizado hacia el jugador
		var direction = to_player.normalized()
		var desired_velocity = direction * speed
		velocity = velocity.lerp(desired_velocity, delta * smoothing)
	else:
		# Se detiene cuando está suficientemente cerca
		velocity = velocity.lerp(Vector2.ZERO, delta * smoothing)

	move_and_slide()
