class_name vaca extends CharacterBody2D

@export var path_node: Path2D
@export var path_speed := 30.0

var on_duty := false
var path_progress := 0.0

func _ready():
	# Nos aseguramos que haya un path válido
	if path_node == null:
		path_node = get_tree().get_root().find_child("vacaPath", true, false)

func _physics_process(delta):
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

func _on_area_martin_o_caucho_body_entered(body: Node2D) -> void:
	if body.name == "Martin" or body.name == "caucho":
		on_duty = true
	if body.name == "Martin" and body.name == "caucho":
		path_speed = 45
	elif body.name == "caucho":
		path_speed = 15
	else:
		path_speed = 30


func _on_area_martin_o_caucho_body_exited(body: Node2D) -> void:
	if body.name == "Martin" or body.name == "caucho":
		# Verificamos si todavía hay uno adentro
		var overlapping: Array[Node2D] = $AreaMartinOCaucho.get_overlapping_bodies()
		on_duty = false
		for b in overlapping:
			if b.name == "Martin" or b.name == "caucho":
				on_duty = true
				break
