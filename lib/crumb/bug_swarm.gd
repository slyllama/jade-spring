@tool
extends Crumb
var rng = RandomNumberGenerator.new()

func clear() -> void:
	Global.announcement_sent.emit("The Dispersion Flux scatters these pests to the Four Winds!")
	Global.bug_crumb_left.emit()
	Global.remove_effect.emit("discombobulator")
	super()

func proc_story() -> void:
		$VisualArea.visible = Save.data.story_point != "game_start"

func _ready() -> void:
	super()
	
	Save.story_advanced.connect(proc_story)
	proc_story()
	
	body_entered.connect(func(body):
		if Save.data.story_point == "game_start": return # not unlocked yet
		if body is CharacterBody3D:
			if !$BugEntry.playing:
				$BugEntry.pitch_scale = 0.9 + rng.randf() * 0.2
				$BugEntry.play()
			
			Global.bug_crumb_entered.emit())
	
	body_exited.connect(func(body):
		if Save.data.story_point == "game_start": return # not unlocked yet
		if body is CharacterBody3D:
			Global.bug_crumb_left.emit())

func interact() -> void:
	if Save.data.story_point == "game_start":
		#Global.announcement_sent.emit("((Comment about bugs))")
		return # not unlocked yet
	
	if "discombobulator" in Global.current_effects:
		var _f = FishingInstance.instantiate()
		_f.completed.connect(clear)
		_f.canceled.connect(func():
			Global.remove_effect.emit("discombobulator"))
		add_child(_f)
	else:
		$Disabled.play()
		Global.announcement_sent.emit(
			"You need Uncharged Dispersion Flux to clear these pests.")
