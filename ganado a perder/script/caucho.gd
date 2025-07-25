class_name caucho extends CharacterBody2D

@export var speed := 250.0
@export var stop_distance := 10.0
@export var smoothing := 5.0
@export var icon_pastorear: Texture
@export var icon_attack: Texture
@export var texture_rect: TextureRect
@onready var caucho_sprite: AnimatedSprite2D = $CauchoSprite
@onready var caucho_area: Area2D = $cauchoArea

var enemigos_en_area: Array[Node2D] = []
var tiempo_entre_ataques := 1.0

var damage := 0.5
var can_attack := true

var vaca: Node2D
var current_order := "pastorear"
var current_target: Node2D = null

func _ready():
	vaca = get_tree().get_first_node_in_group("vaca")
	damage = GlobalStats.caucho_damage

func _physics_process(delta):
	if Input.is_action_just_pressed("orderCaucho"):
		selectOrder()

	Anims()
	match current_order:
		"attackEnemy":
			attackEnemy(delta)
		"pastorear":
			pastorear(delta)

func Anims():
	if velocity.x == 0 and velocity.y == 0:
		caucho_sprite.play("caucho-idle")
	else:
		caucho_sprite.play("caucho-run")

func selectOrder():
	if current_order == "pastorear":
		current_order = "attackEnemy"
	else:
		current_order = "pastorear"
	current_target = null  # reiniciar target al cambiar orden

func pastorear(delta):
	if not vaca:
		return
	texture_rect.texture = icon_pastorear
	var to_vaca = vaca.global_position - global_position
	if to_vaca.length() > stop_distance:
		var direction = to_vaca.normalized()
		var desired_velocity = direction * speed
		velocity = velocity.lerp(desired_velocity, delta * smoothing)
	else:
		velocity = velocity.lerp(Vector2.ZERO, delta * smoothing)

	move_and_slide()

func attackEnemy(delta):
	if not current_target or not is_instance_valid(current_target):
		current_target = get_closest_enemy()
	if not current_target:
		current_order = "pastorear" # <-- Aquí está el cambio clave
		texture_rect.texture = icon_pastorear
		return # Sal de la función attackEnemy, el próximo frame procesará pastorear
	texture_rect.texture = icon_attack
	var to_target = current_target.global_position - global_position
	var direction = to_target.normalized()
	var desired_velocity = direction * speed
	velocity = velocity.lerp(desired_velocity, delta * smoothing)

	move_and_slide()
	
	if can_attack and global_position.distance_to(current_target.global_position) < 20:
		if current_target.has_method("take_damage"):
			current_target.take_damage(damage)
			can_attack = false
			start_attack_cooldown()

func get_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemy: Node2D = null
	var min_distance := INF

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_distance:
			min_distance = dist
			closest_enemy = enemy

	return closest_enemy

func cauchoEntered():
	if not can_attack:
		return
	can_attack = false
	start_attack_cooldown()

func start_attack_cooldown():
	await get_tree().create_timer(1.0).timeout
	can_attack = true


func _on_caucho_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_caucho_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
