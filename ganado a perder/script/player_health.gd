extends TextureProgressBar

@export var player: martin

func _ready() -> void:
	player.healthChanged.connect(update)
	update()

func update():
	value = player.health * 100 / player.maxHealth
