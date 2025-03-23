extends "res://lib/map/map.gd"

func _ready() -> void:
	super()
	
	Global.command_sent.emit("/cleardeco")
	Global.current_effects = []
	Save.data.story_point = "free_reign"
	Save.advance_story()
