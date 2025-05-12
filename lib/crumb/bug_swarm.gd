@tool
extends Crumb
var rng = RandomNumberGenerator.new()

func clear() -> void:
	#Global.announcement_sent.emit("The burst of Raw Dispersion Flux scatters these pests to the Four Winds!")
	Global.bug_crumb_left.emit()
	SteamHandler.add_to_stat("bugs_cleared")
	super()

func proc_story() -> void:
	var _p = Save.data.story_point
	if _p == "game_start" or _p == "pick_weeds": $VisualArea.visible = false
	else: $VisualArea.visible = true

func _update_interact_text() -> void:
	if Global.get_effect_qty("discombobulator_qty") > 0:
		Global.interact_hint = "Clear Bugs"

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	
	Save.story_advanced.connect(proc_story)
	proc_story()
	
	Global.summon_story_panel.connect(func(_data):
		if overlaps_body(Global.player):
			Global.bug_crumb_left.emit())
	
	Global.close_story_panel.connect(func():
		if overlaps_body(Global.player):
			_update_interact_text()
			Global.bug_crumb_entered.emit())
	
	body_entered.connect(func(body):
		if Global.story_panel_open: return
		if body is CharacterBody3D:
			_update_interact_text()
			if !$BugEntry.playing:
				$BugEntry.pitch_scale = 0.9 + rng.randf() * 0.2
				$BugEntry.play()
			Global.bug_crumb_entered.emit())
	
	body_exited.connect(func(body):
		if Global.story_panel_open: return
		if body is CharacterBody3D:
			Global.bug_crumb_left.emit())

func interact() -> void:
	if !Save.is_at_story_point("clear_bugs"):
		Global.announcement_sent.emit("Noisy bugs flick incessantly about me, sending my sensors haywire.")
		return
	else:
		if Global.get_effect_qty("discombobulator_qty") > 0:
			var _new_qty = Global.get_effect_qty("discombobulator_qty") - 1
			Global.remove_effect.emit("discombobulator_qty")
			Global.play_flux_sound()
			for _i in _new_qty: Global.add_qty_effect("discombobulator_qty")
			
			var _f = FishingInstance.instantiate()
			_f.fish_min_speed = 1.1 # make a little easier than Dragonvoid
			_f.fish_max_speed = 1.15
			_f.progress_decrease_rate = 0.38
			_f.completed.connect(clear)
			add_child(_f)
		else:
			$Disabled.play()
			Global.announcement_sent.emit(
				"I'll need some Raw Dispersion Flux to deal with these pests.")
