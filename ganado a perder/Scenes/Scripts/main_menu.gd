extends Node2D  # O Control si es una UI

func _ready():
	# Hacemos que la cámara del menú esté activa por defecto
	$Camera2D.make_current()

func _unhandled_input(event):
	if event.is_action_pressed("enter"):  # Por defecto es Enter / Space
		start_game()

func start_game():
	var game_scene = load("res://Scenes/main.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	get_tree().current_scene.queue_free()
	await get_tree().process_frame
	for enemy in game_scene.get_tree().get_nodes_in_group("enemies"):
		enemy.is_active = true
