extends Node2D

@export var swing_angle := 45.0
@export var swing_duration := 0.2
@export var cooldown := 0.5
@export var attack_offset := Vector2(128, 0)  # Distance from character center

var is_swinging = false
var can_swing = true
var swing_direction := 1.0  # For tracking swing direction

func _ready():
	position = attack_offset

func _process(_delta):
	if Input.is_action_just_pressed("leftClick") and can_swing:
		start_swing()

func start_swing():
	if is_swinging: return
	
	is_swinging = true
	can_swing = false
	
	var pivot = get_parent()
	var mouse_pos = get_global_mouse_position()
	var attack_direction = (mouse_pos - pivot.global_position).normalized()
	
	# Calculate base rotation angle
	var base_rotation = attack_direction.angle()
	
	# Determine swing direction based on mouse position
	swing_direction = sign(attack_direction.x) if abs(attack_direction.x) > 0.1 else 1.0
	
	# Set initial rotation and animate
	pivot.rotation = base_rotation - deg_to_rad(swing_angle) * swing_direction
	
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(pivot, "rotation", 
		base_rotation + deg_to_rad(swing_angle) * swing_direction, 
		swing_duration
	)
	tween.tween_property(pivot, "rotation", base_rotation, swing_duration * 0.5)
	tween.connect("finished", _on_swing_complete)

func _on_swing_complete():
	is_swinging = false
	await get_tree().create_timer(cooldown).timeout
	can_swing = true
