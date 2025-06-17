extends CharacterBody2D

var speed = 100
var dead = false
var health = 1
var damage = 1
var player: Node2D
var is_stunned := false

func _ready() -> void:
	dead = false
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if dead or player == null or is_stunned:
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("bulletEntered"):
		area.bulletEntered()
		take_damage(1)
	elif area.has_method("meleeEntered"):
		take_damage(1)
	elif area.has_method("boleadoraEntered"):
		area.boleadoraEntered()
		stun()
	elif area.name == "cauchoArea" and area.get_parent().has_method("cauchoEntered"):
		area.get_parent().cauchoEntered()
		take_damage(0.5)
	elif area.is_in_group("Player"): # Daño al jugador
		if area.has_method("take_damage"):
			area.take_damage(damage)


func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0 and not dead:
		die()

func die() -> void:
	dead = true
	queue_free()
	
func stun():
	if is_stunned:
		return
	is_stunned = true
	await get_tree().create_timer(5).timeout
	is_stunned = false
