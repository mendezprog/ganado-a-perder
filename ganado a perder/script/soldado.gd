extends CharacterBody2D


var speed = 100
var dead = false
var health = 1
var playerInArea = false
var player

func _ready() -> void:
	dead = false
	
func _physics_process(delta: float) -> void:
	if !dead:
		$Detection/CollisionShape2D.disabled = false
		if playerInArea:
			position += (player.position - position) / speed
	if dead:
		$Detection/CollisionShape2D.disabled = true

func _on_detection_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		playerInArea = true
		player = body

func _on_detection_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		playerInArea = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	var damage
	if area.has_method("bulletEntered"):
		damage = 1
		takeDamage(damage)

func takeDamage(damage):
	health -= damage
	if health <= 0 and !dead:
		death()

func death():
	dead = true
	queue_free()
