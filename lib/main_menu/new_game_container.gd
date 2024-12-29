extends "res://lib/ui_container/ui_container.gd"

signal new_game_button_pressed

func open(silent = false):
	super(silent)
	$Container/NGBox/NewGameButton.grab_focus()

func _on_new_game_button_down() -> void:
	new_game_button_pressed.emit()
	close()

func _on_cancel_button_down() -> void:
	close()

func _on_folder_button_down() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://save"))
