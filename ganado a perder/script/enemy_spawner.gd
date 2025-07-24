extends Node2D

@export var enemy_prefab: PackedScene
@export var spawn_interval: float # Nueva variable para el tiempo del timer

@onready var spawn_timer: Timer = $Timer # Asegúrate de que el nodo Timer se llama "Timer"

func _ready() -> void:
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()

func _on_timer_timeout() -> void:
	if enemy_prefab:
		var enemy = enemy_prefab.instantiate()
		add_child(enemy)
