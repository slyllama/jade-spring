extends Node3D

func _on_collision_interacted() -> void:
	Global.add_effect.emit("discombobulator")
