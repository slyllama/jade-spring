extends "res://lib/map/map.gd"

func _ready() -> void:
	super()
	
	Global.command_sent.connect(func(cmd):
		if cmd == "/giveflux":
			Global.add_effect.emit("discombobulator"))
	
	Global.command_sent.emit("/cleardeco")
	Global.current_effects = []
	Save.data.story_point = "stewardship"
	Save.advance_story()
	
	Global.command_sent.emit("/enableattn")
	await get_tree().create_timer(0.2).timeout # race condition?
	Global.add_effect.emit("discombobulator")
