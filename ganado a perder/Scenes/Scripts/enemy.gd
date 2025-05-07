extends CharacterBody2D

@export var fire_rate: float = 1.5
@export var bullet_scene: PackedScene
@export var damage_amount: int = 20 # Cantidad de daño que inflige el enemigo
@onready var player = $"../Player"
@onready var bullet_spawn_point = $WeaponsPivot/BulletSpawnPoint
@onready var enemy_bullets_container: PackedScene = load("res://Scenes/bullet.tscn")

var time_since_last_shot = 0.0
var is_active = false

func _ready() -> void:
	add_to_group("enemies")

func _process(delta):
	if not is_active or not player:
		return

	look_at(player.global_position)

	time_since_last_shot += delta
	if time_since_last_shot >= fire_rate:
		shoot()
		time_since_last_shot = 0.0

func _physics_process(delta):
	# Detectar colisiones con el jugador
	var collision_info = move_and_collide(velocity * delta)
	if collision_info and collision_info.collider.is_in_group("player"):
		# Llamar a una función en el jugador para que reciba daño
		if player.has_method("take_damage"):
			player.take_damage(damage_amount)
			print(damage_amount)

func shoot():
	if not bullet_scene or not enemy_bullets_container:
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn_point.global_position

	var direction = (player.global_position - bullet.global_position).normalized()
	bullet.velocity = direction * bullet.speed
	bullet.is_friendly = false

	enemy_bullets_container.add_child(bullet)
