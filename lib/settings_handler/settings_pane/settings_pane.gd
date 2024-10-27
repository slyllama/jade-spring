extends "res://lib/ui_container/ui_container.gd"

func close() -> void:
	SettingsHandler.save_to_file()
	super()
