extends "res://lib/ui_container/ui_container.gd"

signal continued

func _on_menu_button_down() -> void:
	close()

func _on_open_saves_button_down() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://save"))

func _on_continue_anyway_button_down() -> void:
	continued.emit()
	close()
