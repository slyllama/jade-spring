extends "res://lib/gadget/gadget.gd"

const AttenuatorUI = preload("res://lib/attenuator/attenuator.tscn")
var in_ui = false

func _on_interacted() -> void:
	if in_ui: return # don't open multiple
	else: in_ui = true
	
	if "discombobulator" in Global.current_effects:
		Global.remove_effect.emit("discombobulator")
		Global.add_effect.emit("dv_charge")
	
	var _ui = AttenuatorUI.instantiate()
	Global.hud.add_child(_ui)
	_ui.closed.connect(func():
		in_ui = false
		in_range = true
		Global.generic_area_entered.emit()
		Global.action_cam_enable.emit())
