@tool
extends Crumb
var rng = RandomNumberGenerator.new()

func clear() -> void:
	Global.bug_crumb_left.emit()
	super()

func _ready() -> void:
	super()
	body_entered.connect(func(body):
		if body is CharacterBody3D:
			if !$BugEntry.playing:
				$BugEntry.pitch_scale = 0.9 + rng.randf() * 0.2
				$BugEntry.play()
			Global.bug_crumb_entered.emit())
	
	body_exited.connect(func(body):
		if body is CharacterBody3D:
			Global.bug_crumb_left.emit())

func interact() -> void:
	if "discombobulator" in Global.current_effects:
		var _f = FishingInstance.instantiate()
		_f.completed.connect(clear)
		add_child(_f)
	else:
		Global.announcement_sent.emit(
			"You need a Discombobulator to clear these pests.")
