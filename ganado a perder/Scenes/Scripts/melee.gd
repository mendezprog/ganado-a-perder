extends Node2D

@export var swing_angle := 120.0
@export var swing_duration := 0.1
@export var cooldown := 0.3
@export var attack_offset := Vector2(30, 0)

var is_swinging = false
var can_swing = true
var swing_direction := 1.0

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
	
	var base_rotation = attack_direction.angle()
	
	swing_direction = sign(attack_direction.x) if abs(attack_direction.x) > 0.1 else 1.0
	
	var start_rotation = base_rotation - deg_to_rad(swing_angle/2 * swing_direction)
	var end_rotation = base_rotation + deg_to_rad(swing_angle/2 * swing_direction)
	
	pivot.rotation = start_rotation
	
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(pivot, "rotation", 
		end_rotation, swing_duration)
	
	tween.tween_property(pivot, "rotation", base_rotation, swing_duration * 0.5)
	
	# Wait for BOTH the tween AND cooldown
	await tween.finished
	await get_tree().create_timer(cooldown).timeout  # Moved cooldown here
	
	is_swinging = false
	can_swing = true
