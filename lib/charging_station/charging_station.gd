@tool
extends "res://lib/gadget/gadget.gd"

var in_ui = false

func _update_interact_text() -> void:
	if Global.get_effect_qty("discombobulator_qty") > 0:
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

	if Global.get_effect_qty("discombobulator_qty") > 0:
		var _new_qty = Global.get_effect_qty("discombobulator_qty") - 1
		Global.remove_effect.emit("discombobulator_qty")
		Global.play_flux_sound()
		for _i in _new_qty: Global.add_qty_effect("discombobulator_qty")
		var _ui_loader = load("res://lib/attenuator/scripts/att_ui_loader.gd").new()
		_ui_loader.pulled.connect(func(resource: Resource):
			var _ui = resource.instantiate()
			Global.hud.get_node("TopLevel").add_child(_ui)
			in_ui = true
			_ui.closed.connect(func():
				in_ui = false
				in_range = true
				Global.generic_area_entered.emit()
				Global.action_cam_enable.emit()
			)
			_ui_loader.queue_free()
		)
		add_child(_ui_loader)
		
	else:
		Global.announcement_sent.emit("This attunement gadget charges Raw Dispersion Flux.")
		return
