extends Node2D

@export var enemy_prefab: PackedScene

func _on_timer_timeout() -> void:
	if enemy_prefab: # Check if a PackedScene has been assigned
		var enemy = enemy_prefab.instantiate()
		add_child(enemy)
	else:
		# Optional: Add a warning or handle the case where no enemy is set
		# print("Warning: No enemy prefab assigned to this spawner.")
		pass # Do nothing if no enemy prefab is assigned
