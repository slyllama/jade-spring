extends "res://lib/map/map.gd"

func _ready() -> void:
	super()
	Global.command_sent.emit("/cleardeco")

func _process(_delta: float) -> void:
	$HUD/DebugTL/DebugButtons/FXDebug.text = str(Global.current_effects)
	$HUD/DebugTL/DebugButtons/FXDebug.text += "\n" + str(Save.data)

func _on_add_weed_button_down() -> void:
	Global.add_qty_effect("weed")

func _on_clear_weeds_button_down() -> void:
	Global.remove_effect.emit("weed")
