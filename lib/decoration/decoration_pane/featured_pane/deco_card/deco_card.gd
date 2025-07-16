extends Panel

func _init() -> void:
	modulate.a = 0.9

func _on_mouse_entered() -> void:
	modulate.a = 1.2

func _on_mouse_exited() -> void:
	modulate.a = 0.9
