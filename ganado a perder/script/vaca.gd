class_name vaca extends CharacterBody2D


@export var path_node: Path2D
@export var path_speed := 30.0
@onready var vaca_sprite: AnimatedSprite2D = $vacaSprite
@onready var puma_damage: Area2D = $pumaDamage
@onready var timer: Timer = $Timer

var on_duty := false
var path_progress := 0.0
var pumas_en_area: Array[Node2D] = []

func _ready():
	# Nos aseguramos que haya un path válido
	if path_node == null:
		path_node = get_tree().get_root().find_child("vacaPath", true, false)

func _physics_process(delta):
	anims()
	if not on_duty or path_node == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Avanzar en el camino
	path_progress += path_speed * delta
	var path = path_node.curve
	if path_progress > path.get_baked_length():
		path_progress = path.get_baked_length()

	var next_position = path.sample_baked(path_progress)
	var direction = (next_position - global_position).normalized()
	velocity = direction * path_speed
	move_and_slide()

func anims():
	if velocity.x == 0 and velocity.y == 0:
		vaca_sprite.play("vaca-idle")
	elif velocity.y > 0:
		vaca_sprite.play("vaca-down")
	elif velocity.y < 0:
		vaca_sprite.play("vaca-up")
	elif velocity.x > 0:
		vaca_sprite.play("vaca-side")
		vaca_sprite.flip_h = false
	elif velocity.x < 0:
		vaca_sprite.play("vaca-side")
		vaca_sprite.flip_h = true

func _on_area_martin_o_caucho_body_entered(body: Node2D) -> void:
	if body.name == "martin" or body.name == "caucho":
		on_duty = true
	if body.name == "martin" and body.name == "caucho":
		on_duty = true
		path_speed = 45
	elif body.name == "caucho":
		on_duty = true
		path_speed = 15
	else:
		path_speed = 30

func _on_area_martin_o_caucho_body_exited(body: Node2D) -> void:
	if body.name == "martin" or body.name == "caucho":
		# Verificamos si todavía hay uno adentro
		var overlapping: Array[Node2D] = $AreaMartinOCaucho.get_overlapping_bodies()
		on_duty = false
		for b in overlapping:
			if b.name == "martin":
				on_duty = true
				path_speed = 30
			elif b.name == "caucho":
				on_duty = true
				path_speed = 15
				break

func _on_puma_damage_body_entered(body: Node2D) -> void:
	if body.name == "puma":
		if not pumas_en_area.has(body):
			pumas_en_area.append(body)
		if not timer.is_stopped():
			return
		timer.start()

func _on_puma_damage_body_exited(body: Node2D) -> void:
	if body.name == "puma":
		pumas_en_area.erase(body)
		if pumas_en_area.is_empty():
			timer.stop()

func _on_timer_timeout() -> void:
	GlobalStats.emit_signal("vaca_perdida")
