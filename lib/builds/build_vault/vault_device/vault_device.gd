extends Node3D

func _on_gadget_interacted() -> void:
	Global.command_sent.emit("/vault")
