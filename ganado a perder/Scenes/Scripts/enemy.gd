extends CharacterBody2D

@export var fire_rate: float = 1.5
@export var bullet_scene: PackedScene
@onready var player = get_tree().get_first_node_in_group("player")
@onready var bullet_spawn_point = $WeaponsPivot/BulletSpawnPoint

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

func shoot():
	if not bullet_scene:
		return
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn_point.global_position
	
	var direction = (player.global_position - bullet.global_position).normalized()
	bullet.velocity = direction * bullet.speed
	bullet.is_friendly = false
	
	get_tree().current_scene.add_child(bullet)
