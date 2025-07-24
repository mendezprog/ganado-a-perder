extends CharacterBody2D

var speed = 150
var dead = false
var health = 1
var damage = 1
var vaca: Node2D
var is_stunned := false
@onready var effects: AnimationPlayer = $effects
@onready var puma_sprite: AnimatedSprite2D = $pumaSprite


func _ready() -> void:
	effects.play("RESET")
	dead = false
	vaca = get_tree().get_first_node_in_group("vaca")
	
	match get_tree().current_scene.name:
		"lvl1":
			health = 1
		"lvl2":
			health = 2
		"lvl3":
			health = 4
		_:
			health = 1  # valor por defecto

func _physics_process(delta: float) -> void:
	if dead or vaca == null or is_stunned:
		return

	var direction = (vaca.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	anims()

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
	elif area.is_in_group("vaca"): # Daño a la vaca
		puma_sprite.play("attack")
		await get_tree().create_timer(0.5).timeout

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
	queue_free()
	
func stun():
	if is_stunned:
		return
	is_stunned = true
	await get_tree().create_timer(5).timeout
	is_stunned = false

func anims():
	if velocity.y == 0:
		puma_sprite.play("idle")
	elif velocity.x > 0:
		puma_sprite.play("run-side")
		puma_sprite.flip_h = false
	elif velocity.x < 0:
		puma_sprite.play("run-side")
		puma_sprite.flip_h = true
