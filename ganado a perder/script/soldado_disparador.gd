extends CharacterBody2D

var speed = 25
var dead = false
var health = 1
var damage = 1
var player: Node2D
var is_stunned := false
var shoot_timer := 0.0
const SHOOT_INTERVAL := 3.0
const FOLLOW_DISTANCE := 150.0
@onready var pick_up_spawn_point: Marker2D = $pickUpSpawnPoint
const pick_up_bullets = preload("res://Scenes/pick_up_bullets.tscn")

@onready var effects: AnimationPlayer = $effects
@onready var visibility_notifier: VisibleOnScreenNotifier2D = $visibility_notifier
@export var bullet_scene: PackedScene  # Cargá tu escena de bala desde el editor

func _ready() -> void:
	effects.play("RESET")
	dead = false
	player = get_tree().get_first_node_in_group("Player")
	
	match get_tree().current_scene.name:
		"lvl1":
			health = 1
		"lvl2":
			health = 2
		"lvl3":
			health = 4
		_:
			health = 1

func _physics_process(delta: float) -> void:
	if dead or player == null or is_stunned:
		return

	var to_player = player.global_position - global_position
	var distance = to_player.length()

	# Movimiento solo si está cerca
	if distance >= FOLLOW_DISTANCE:
		var direction = to_player.normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

	# Solo dispara si está visible
	if visibility_notifier.is_on_screen():
		shoot_timer += delta
		if shoot_timer >= SHOOT_INTERVAL:
			shoot()
			shoot_timer = 0.0

func shoot():
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.look_at(player.global_position)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("bulletEntered"):
		area.bulletEntered()
		take_damage(1)
	elif area.has_method("meleeEntered"):
		take_damage(GlobalStats.facon_damage)
	elif area.has_method("boleadoraEntered"):
		area.boleadoraEntered()
		stun()
	elif area.name == "cauchoArea" and area.get_parent().has_method("cauchoEntered"):
		area.get_parent().cauchoEntered()
		take_damage(GlobalStats.caucho_damage)
	elif area.is_in_group("Player"): # Daño al jugador
		if area.has_method("bulletEnteredMartin"):
			area.take_damage(damage)

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0 and not dead:
		die()
		return
	effects.play("hurtBlink")
	await get_tree().create_timer(0.5).timeout
	effects.play("RESET")

func die() -> void:
	dead = true
	# Pasamos la global_position del Marker2D a la función diferida
	call_deferred("_spawn_pickup_bullets", pick_up_spawn_point.global_position)
	queue_free()
	
func _spawn_pickup_bullets(spawn_position: Vector2) -> void:
	# Asegúrate de que el soldado (self) sigue siendo válido si es que importara para algo,
	# aunque en este caso ya pasamos la posición directamente.
	if is_instance_valid(self): 
		var pickup_instance = pick_up_bullets.instantiate()
		pickup_instance.global_position = spawn_position
		
		# Añade la instancia a la raíz del árbol de la escena
		get_tree().root.add_child(pickup_instance)
func stun():
	if is_stunned:
		return
	is_stunned = true
	await get_tree().create_timer(5).timeout
	is_stunned = false
