extends Control

@onready var main_belt: Sprite2D = $MainBelt
@export var textures: Array[Texture2D] # Orden: melee, trabuco, boleadoras
@onready var ammo: RichTextLabel = $MainBelt/HBoxContainer/trabuco/ammo

var weapon_texture_indices := {
	"melee": 0,
	"trabuco": 1,
	"boleadoras": 2
}

var player: Node = null

func _ready():
	# Buscar al jugador en la escena actual
	await get_tree().process_frame # Esperamos a que se instancie todo
	player = get_tree().get_first_node_in_group("Player")
	if player:
		player.weapon_changed.connect(_on_weapon_changed)
		_on_weapon_changed(player.currentWeapon) # Sincronizamos textura inicial

func _process(delta):
	if player and player.currentWeapon == "trabuco":
		ammo.text = "%d/%d" % [player.trabucoCurrentAmmo, player.trabucoMaxAmmo]

func _on_weapon_changed(weapon_name: String):
	if weapon_name in weapon_texture_indices:
		var index = weapon_texture_indices[weapon_name]
		if index < textures.size():
			main_belt.texture = textures[index]

	# Mostrar munición solo si el arma es el trabuco
	if weapon_name == "trabuco" and player:
		ammo.visible = true
		ammo.text = "%d/%d" % [player.trabucoCurrentAmmo, player.trabucoMaxAmmo]
	else:
		ammo.visible = false
