extends "res://lib/ui_container/ui_container.gd"

func _on_test_deco_button_down() -> void:
	Global.tool_mode = Global.TOOL_MODE_PLACE
	Global.queued_decoration = "test_decoration"
	Global.deco_placement_started.emit()
	Global.set_cursor(true, {
		"highlight_on_decoration": false,
		"radius": 3.0,
		"custom_model": load("res://decorations/lantern/lantern.glb")
	})
