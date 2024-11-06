extends "res://lib/ui_container/ui_container.gd"

func _on_test_deco_button_down() -> void:
	Global.set_cursor(true, {
		"highlight_on_decoration": false,
		"radius": 3.0
	})
