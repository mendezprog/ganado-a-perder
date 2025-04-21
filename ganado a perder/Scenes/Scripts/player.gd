extends CharacterBody2D

enum WeaponType { MELEE, GUN, BOLEADORAS }
var current_weapon : WeaponType = WeaponType.MELEE

@onready var melee = $WeaponsPivot/Melee
@onready var gun = $WeaponsPivot/trabuco
@onready var boleadora_scene = preload("res://Scenes/boleadora.tscn")

@export var speed: int = 250
@export var roll_speed: int = 600
@export var roll_duration: float = 0.3
@export var roll_cooldown: float = 0.3
@export var bullet_scene: PackedScene = load("res://Scenes/bullet.tscn")
@export var spread_angle_deg: float = 45.0
@export var pellet_count: int = 5

var is_rolling = false
var roll_direction = Vector2.ZERO
var roll_timer = 0.0
var cooldown_timer = 0.0
var can_shoot = true
@export var shoot_cooldown: float = 10.0

func _ready() -> void:
	position = Vector2(100, 500)

func _process(delta: float) -> void:
	# Cooldown management
	if cooldown_timer > 0:
		cooldown_timer -= delta

	# If currently rolling
	if is_rolling:
		roll_timer -= delta
		velocity = roll_direction * roll_speed
		move_and_slide()

		if roll_timer <= 0:
			is_rolling = false
			cooldown_timer = roll_cooldown
	else:
		movement()
		
		# Trigger roll
		if Input.is_action_just_pressed("rightClick") and cooldown_timer <= 0:
			var input_direction = Input.get_vector("left", "right", "up", "down")
			if input_direction != Vector2.ZERO:
				roll(input_direction)
				
	if Input.is_action_just_pressed("1"):
		select_weapon(WeaponType.MELEE)
	elif Input.is_action_just_pressed("2"):
		select_weapon(WeaponType.GUN)
	elif Input.is_action_just_pressed("3"):
		select_weapon(WeaponType.BOLEADORAS)
		
	if Input.is_action_just_pressed("leftClick"):
		match current_weapon:
			WeaponType.MELEE:
				melee.start_swing()
			WeaponType.GUN:
				shoot()
			WeaponType.BOLEADORAS:
				launch_boleadora()

func movement() -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()

func roll(direction: Vector2) -> void:
	is_rolling = true
	roll_direction = direction.normalized()
	roll_timer = roll_duration
	
func shoot():
	if not can_shoot:
		return

	can_shoot = false  # Block future shots right away
	
	var mouse_pos = get_global_mouse_position()
	var base_direction = (mouse_pos - global_position).normalized()
	
	# Get reference to the PlayerBullets node
	var bullet_container = $"../PlayerBullets"
	if bullet_container == null:
		print("PlayerBullets node not found!")
		return
	
	for i in range(pellet_count):
		var spread = deg_to_rad(randf_range(-spread_angle_deg / 2, spread_angle_deg / 2))
		var rotated_direction = base_direction.rotated(spread)
		
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.velocity = rotated_direction * bullet.speed
		bullet_container.add_child(bullet)
	# Start cooldown *after* shooting
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
	
func launch_boleadora():
	var boleadora = boleadora_scene.instantiate()
	boleadora.global_position = $WeaponsPivot.global_position
	
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - boleadora.global_position).normalized()
	boleadora.direction = direction
	
	get_tree().current_scene.add_child(boleadora)
	
func select_weapon(weapon: WeaponType):
	current_weapon = weapon
	melee.visible = (weapon == WeaponType.MELEE)
	$WeaponsPivot/trabuco.visible = (weapon == WeaponType.GUN)
	# Las boleadoras no tienen un sprite en el jugador, así que no se cambia nada más
