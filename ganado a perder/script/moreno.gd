extends CharacterBody2D

var speed = 50
var charge_speed = 350
var charge_duration = 0.2
var dead = false
var health = 75
var damage = 5
var player: Node2D
var is_stunned := false
var is_charging := false

func _ready() -> void:
	dead = false
	player = get_tree().get_first_node_in_group("Player")

	start_charge_loop()

func _physics_process(delta: float) -> void:
	if dead or player == null or is_stunned:
		return
	if position.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	var direction = (player.global_position - global_position).normalized()
	var current_speed = charge_speed if is_charging else speed
	velocity = direction * current_speed
	move_and_slide()

func start_charge_loop() -> void:
	await get_tree().create_timer(5).timeout
	while not dead:
		await charge()
		await get_tree().create_timer(5).timeout

func charge() -> void:
	is_charging = true
	await get_tree().create_timer(charge_duration).timeout
	is_charging = false

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
		take_damage(0.5)
	elif area.is_in_group("Player"):
		if area.has_method("moreno_damage"):
			area.moreno_damage()

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0 and not dead:
		die()

func die() -> void:
	dead = true
	call_deferred("changeLevel")
	queue_free()

func changeLevel():
	get_tree().change_scene_to_file("res://Scenes/creditos.tscn")
func stun():
	if is_stunned:
		return
	is_stunned = true
	await get_tree().create_timer(5).timeout
	is_stunned = false
