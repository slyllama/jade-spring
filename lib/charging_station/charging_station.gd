@tool
extends "res://lib/gadget/gadget.gd"

const AttenuatorUI = preload("res://lib/attenuator/attenuator.tscn")
var in_ui = false

func _update_interact_text() -> void:
	if "discombobulator" in Global.current_effects:
			Global.interact_hint = "Attune"

func proc_story() -> void:
	if Save.is_at_story_point("clear_dv"):
		visible = true
		active = true
	else:
		visible = false
		active = false

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	Save.story_advanced.connect(proc_story)
	proc_story()
	
	body_entered.connect(func(body):
		if body == Global.player:
			_update_interact_text())
	
	Global.summon_story_panel.connect(func(_data):
		if overlaps_body(Global.player):
			Global.generic_area_left.emit())
	
	Global.close_story_panel.connect(func():
		if overlaps_body(Global.player):
			_update_interact_text()
			Global.generic_area_entered.emit())
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/enableattn":
			visible = true
			active = true
		elif _cmd == "/disableattn":
			visible = false
			active = false
			if in_range:
				Global.generic_area_left.emit())

func _on_interacted() -> void:
	if in_ui: return # don't open multiple
	
	if !"discombobulator" in Global.current_effects:
		Global.announcement_sent.emit("This attunement gadget charges Raw Dispersion Flux.")
		return
	
	in_ui = true
	var _ui = AttenuatorUI.instantiate()
	Global.hud.get_node("TopLevel").add_child(_ui)
	_ui.closed.connect(func():
		in_ui = false
		in_range = true
		Global.generic_area_entered.emit()
		Global.action_cam_enable.emit())
