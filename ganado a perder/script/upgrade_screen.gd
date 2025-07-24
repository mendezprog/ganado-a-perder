extends Control

@onready var label: RichTextLabel = $MejorasMenu/RichTextLabel
@onready var salud := $MejorasMenu/HBoxContainer/Salud
@onready var balas := $MejorasMenu/HBoxContainer/Balas
@onready var cauchoDMG := $MejorasMenu/HBoxContainer/Caucho
@onready var confirmar: Button = $MejorasMenu/Confirmar
@onready var siguiente_nivel: Button = $MejorasMenu/SiguienteNivel
@onready var cuidadora: AnimatedSprite2D = $MejorasMenu/Cuidadora
@onready var cocinera: AnimatedSprite2D = $MejorasMenu/Cocinera
@onready var armero: AnimatedSprite2D = $MejorasMenu/Armero


var selected_upgrades := []

func _ready():
	salud.connect("mouse_entered", _on_salud_mouse_entered)
	salud.connect("mouse_exited", _on_mouse_exited)
	salud.connect("pressed", _on_salud_pressed)

	balas.connect("mouse_entered", _on_balas_mouse_entered)
	balas.connect("mouse_exited", _on_mouse_exited)
	balas.connect("pressed", _on_balas_pressed)

	cauchoDMG.connect("mouse_entered", _on_cauchoDMG_mouse_entered)
	cauchoDMG.connect("mouse_exited", _on_mouse_exited)
	cauchoDMG.connect("pressed", _on_cauchoDMG_pressed)

	confirmar.connect("pressed", _on_confirmar_pressed)
	siguiente_nivel.connect("pressed", _on_siguiente_nivel_pressed)
	siguiente_nivel.disabled = true
	
	cuidadora.play("idle")
	cocinera.play("idle")
	armero.play("idle")

func _on_salud_mouse_entered():
	label.text = "Incrementa la salud máxima de Martín (suma 5 puntos de salud)."

func _on_balas_mouse_entered():
	label.text = "Aumenta la capacidad máxima de munición del trabuco en 5 unidades y baja el tiempo de recarga 0.3 segundos."

func _on_cauchoDMG_mouse_entered():
	label.text = "Aumenta el daño que Caucho inflige en 0.5 puntos."

func _on_mouse_exited():
	label.text = ""

func _on_salud_pressed():
	_toggle_upgrade("salud", salud)

func _on_balas_pressed():
	_toggle_upgrade("balas", balas)

func _on_cauchoDMG_pressed():
	_toggle_upgrade("cauchoDMG", cauchoDMG)

func _toggle_upgrade(upgrade_name: String, button: BaseButton):
	if selected_upgrades.has(upgrade_name):
		selected_upgrades.erase(upgrade_name)
		button.modulate = Color.WHITE
	else:
		if selected_upgrades.size() < 2:
			selected_upgrades.append(upgrade_name)
			button.modulate = Color.LIGHT_GREEN

func _on_confirmar_pressed():
	if selected_upgrades.size() != 2:
		label.text = "Debes elegir exactamente 2 mejoras."
		return

	for upgrade in selected_upgrades:
		match upgrade:
			"salud":
				GlobalStats.martin_max_health += 5
			"balas":
				GlobalStats.trabuco_max_ammo += 5
				GlobalStats.trabuco_reload_time -= 0.3
			"cauchoDMG":
				GlobalStats.caucho_damage += 0.5

	confirmar.disabled = true
	siguiente_nivel.disabled = false
	label.text = "¡Mejoras aplicadas! Podés continuar."

func _on_siguiente_nivel_pressed():
	var next_scene := ""

	match GlobalStats.current_level:
		0:
			next_scene = "res://Niveles/lvl1.tscn"
		1:
			next_scene = "res://Niveles/lvl2.tscn"
		2:
			next_scene = "res://Niveles/lvl3.tscn"
		3:
			next_scene = "res://Niveles/lvlfinal.tscn"
		_:
			print("Nivel no válido:", GlobalStats.current_level)
			return

	get_tree().change_scene_to_file(next_scene)
