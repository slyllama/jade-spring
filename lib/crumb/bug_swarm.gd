@tool
extends Crumb
var rng = RandomNumberGenerator.new()

func clear() -> void:
	#Global.announcement_sent.emit("The burst of Raw Dispersion Flux scatters these pests to the Four Winds!")
	Global.bug_crumb_left.emit()
	Global.remove_effect.emit("discombobulator")
	super()

func proc_story() -> void:
	var _p = Save.data.story_point
	if _p == "game_start" or _p == "pick_weeds": $VisualArea.visible = false
	else: $VisualArea.visible = true

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	
	Save.story_advanced.connect(proc_story)
	proc_story()
	
	Global.close_story_panel.connect(func():
		if overlaps_body(Global.player):
			Global.bug_crumb_entered.emit())
	
	body_entered.connect(func(body):
		if Global.in_exclusive_ui: return
		if body is CharacterBody3D:
			if !$BugEntry.playing:
				$BugEntry.pitch_scale = 0.9 + rng.randf() * 0.2
				$BugEntry.play()
			
			Global.bug_crumb_entered.emit())
	
	body_exited.connect(func(body):
		if Global.in_exclusive_ui: return
		if body is CharacterBody3D:
			Global.bug_crumb_left.emit())

func interact() -> void:
	if (Save.data.story_point == "game_start"
		or Save.data.story_point == "pick_weeds"):
		Global.announcement_sent.emit("Noisy bugs flick incessantly about me, sending my sensors haywire.")
		return # not unlocked yet
	elif (Save.data.story_point == "clear_bugs" 
		or Save.data.story_point == "ratchet_dv"
		or Save.data.story_point == "clear_dv"
		or Save.data.story_point == "ratchet_gratitude"
		or Save.data.story_point == "gratitude"
		or Save.data.story_point == "stewardship"):
		if "discombobulator" in Global.current_effects:
			var _f = FishingInstance.instantiate()
			_f.fish_min_speed = 1.1 # make a little easier than Dragonvoid
			_f.fish_max_speed = 1.15
			_f.progress_decrease_rate = 0.38
			_f.completed.connect(clear)
			_f.canceled.connect(func():
				Global.remove_effect.emit("discombobulator"))
			add_child(_f)
		else:
			$Disabled.play()
			Global.announcement_sent.emit(
				"I'll need some Raw Dispersion Flux to deal with these pests.")
