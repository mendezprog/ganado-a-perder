extends CharacterBody2D

var currentWeapon := "melee"

const WEAPON_KEYS := {
	"1": "melee",
	"2": "trabuco",
	"3": "boleadoras"
}

@onready var WEAPONS := {
	"melee": {
		"sprite": $meleePivot/faconSprite,
		"collider": $meleePivot/faconCollision
	},
	"trabuco": {
		"sprite": $trabucoSprite
	},
	"boleadoras": {
		"sprite": $boleadoraSprite
	}
}

var health = 20
var dead = false
var speed = 250
var preventRotation := false
var playerState
var lastDirection := Vector2.DOWN
var trabucoCooldown = true
var trabucoBullet = preload("res://scenes/bullet.tscn")
var boleadoraInstance = preload("res://scenes/boleadora.tscn")
var meleeAttacking := false
var boleadorasAmmo := 3
const MAX_BOLEADORAS := 3
const BOLEADORAS_RELOAD_TIME := 5.0
var canThrowBoleadora := true
@onready var meleeSprite: AnimatedSprite2D = $meleePivot/faconSprite
@onready var meleeCollider: CollisionPolygon2D = $meleePivot/faconCollision

var isRolling = false
var rollSpeed = 350
var rollDirection = Vector2.ZERO

func _ready() -> void:
	$trabucoSprite.hide()
	meleeSprite.hide()
	meleeCollider.disabled = true
	$boleadoraSprite.hide()
	$boleadoraSprite.play("boleadora-idle-martin")
	start_boleadoras_reload()

func _physics_process(delta: float) -> void:
	if isRolling:
		velocity = rollDirection * rollSpeed
		move_and_slide()
		return
		
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		lastDirection = direction.normalized()
		playerState = "moving"
	else:
		playerState = "idle"
	
	velocity = direction * speed
	move_and_slide()
	
	weaponSelector()
	if Input.is_action_just_pressed("rightClick") and not isRolling:
		start_roll()
	
	var mousePos = get_global_mouse_position()
	$Marker2D.look_at(mousePos)

# Apunta el arma actual al mouse
	match currentWeapon:
		"trabuco":
			$trabucoSprite.look_at(mousePos)
			if Input.is_action_just_pressed("leftClick") and trabucoCooldown:
				$trabucoSprite.play("trabuco-shoot")
				trabucoCooldown = false

				# Dispara 5 balas en arco de 70°
				var base_angle: float = $Marker2D.global_position.angle_to_point(mousePos)
				for i in 5:
					var bullet = trabucoBullet.instantiate()
					var spread_deg := randf_range(-15.0, 15.0)
					var spread_rad := deg_to_rad(spread_deg)
					bullet.rotation = base_angle + spread_rad
					bullet.global_position = $Marker2D.global_position
					add_child(bullet)

				await get_tree().create_timer(0.5).timeout
				$trabucoSprite.play("trabuco-reload")
				await get_tree().create_timer(2).timeout
				$trabucoSprite.play("trabuco-idle")
				trabucoCooldown = true

		"melee":
			if not preventRotation:
				$meleePivot.look_at(mousePos)
			if Input.is_action_just_pressed("leftClick") and not meleeAttacking:
				meleeAttacking = true
				preventRotation = true

				meleeSprite.show()
				meleeSprite.play("swing")

				# Pequeño retraso antes de activar la colisión (puede coincidir con el frame efectivo del golpe)
				await get_tree().create_timer(0.1).timeout
				meleeCollider.disabled = false
				meleeCollider.show()

				# Ventana activa del golpe
				await get_tree().create_timer(0.2).timeout
				meleeCollider.disabled = true
				meleeCollider.hide()

				meleeSprite.hide()
				meleeAttacking = false
				preventRotation = false

		"boleadoras":
			$boleadoraSprite.look_at(mousePos)
			if Input.is_action_just_pressed("leftClick") and canThrowBoleadora and boleadorasAmmo > 0:
				canThrowBoleadora = false
				boleadorasAmmo -= 1

				var boleadora = boleadoraInstance.instantiate()
				boleadora.global_position = $Marker2D.global_position
				boleadora.rotation = $Marker2D.global_position.angle_to_point(mousePos)
				add_child(boleadora)

				await get_tree().create_timer(1).timeout  # Cooldown para evitar spam
				canThrowBoleadora = true
			if boleadorasAmmo == 0:
				$boleadoraSprite.hide()
			else:
				$boleadoraSprite.show()
				
	playAnim()

func playAnim():
	var dir := lastDirection
	if playerState == "moving":
		dir = velocity.normalized()

	var is_diagonal: bool = abs(dir.x) > 0.1 and abs(dir.y) > 0.1
	var is_facing_left: bool = dir.x < 0

	if abs(dir.x) > 0.1:
		$martinSprite.flip_h = is_facing_left

	if playerState == "idle":
		if abs(dir.y) > 0.1:
			if dir.y < 0:
				$martinSprite.play("north-idle")
			else:
				$martinSprite.play("south-idle")
		elif abs(dir.x) > 0.1:
			$martinSprite.play("side-idle")

	elif playerState == "moving":
		if is_diagonal:
			if dir.y < 0:
				$martinSprite.play("north-diagonal-running")
			else:
				$martinSprite.play("south-diagonal-running")
		elif abs(dir.y) > 0.1:
			if dir.y < 0:
				$martinSprite.play("north-running")
			else:
				$martinSprite.play("south-running")
		elif abs(dir.x) > 0.1:
			$martinSprite.play("side-running")

func weaponSelector():
	for key in WEAPON_KEYS.keys():
		if Input.is_action_just_pressed(key):
			var weapon_name = WEAPON_KEYS[key]
			equip_weapon(weapon_name)
			break
			

func equip_weapon(weapon_name: String):
	# Ocultar todas las armas
	for weapon in WEAPONS.values():
		if weapon.has("sprite"):
			weapon["sprite"].hide()
		if weapon.has("collider"):
			weapon["collider"].disabled = true
			weapon["collider"].hide()

	# Resetear estado melee si se está cambiando de arma
	if currentWeapon == "melee":
		meleeAttacking = false
		preventRotation = false
		meleeSprite.hide()
		meleeCollider.disabled = true
		meleeCollider.hide()

	# Mostrar solo el arma seleccionada
	var selected = WEAPONS.get(weapon_name)
	if selected:
		if selected.has("sprite") and (weapon_name == "trabuco") or (weapon_name == "boleadoras"):
			selected["sprite"].show()
		if selected.has("collider"):
			selected["collider"].disabled = true  # desactivado por defecto hasta que ataques

	currentWeapon = weapon_name


func start_roll():
	isRolling = true
	$martinCollision.hide()
	rollDirection = lastDirection.normalized()
	playerState = "rolling"

	var dir = rollDirection
	var is_diagonal = abs(dir.x) > 0.1 and abs(dir.y) > 0.1

	if is_diagonal:
		if dir.x > 0 and dir.y < 0:
			$martinSprite.play("north-diagonal-rolling")
			$martinSprite.flip_h = false
		elif dir.x < 0 and dir.y < 0:
			$martinSprite.play("north-diagonal-rolling")
			$martinSprite.flip_h = false
		elif dir.x > 0 and dir.y > 0:
			$martinSprite.play("south-diagonal-rolling")
			$martinSprite.flip_h = false
		elif dir.x < 0 and dir.y > 0:
			$martinSprite.play("south-diagonal-rolling")
			$martinSprite.flip_h = false
	else:
		if abs(dir.x) > abs(dir.y):
			if dir.x > 0:
				$martinSprite.play("side-rolling")
				$martinSprite.flip_h = false
			else:
				$martinSprite.play("side-rolling")
				$martinSprite.flip_h = true
		else:
			if dir.y > 0:
				$martinSprite.play("south-rolling")
			else:
				$martinSprite.play("north-rolling")

	await get_tree().create_timer(0.4).timeout
	isRolling = false
	playerState = "idle"
	$martinCollision.show()

func player():
	pass
	
func start_boleadoras_reload():
	await get_tree().create_timer(BOLEADORAS_RELOAD_TIME).timeout
	if boleadorasAmmo < MAX_BOLEADORAS:
		boleadorasAmmo += 1
	start_boleadoras_reload()  # Reinicia la recarga automática
