extends PanelContainer

signal closed

func _on_dismiss_pressed() -> void:
	closed.emit()
