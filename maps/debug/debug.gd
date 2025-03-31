extends "res://lib/map/map.gd"

func _ready() -> void:
	super()
	$PulleyMesh/AnimationPlayer.play("Base")
	
	Global.hud.get_node("SidePanel").modulate.a = 1.0 # just for debug
	
	Global.command_sent.connect(func(cmd):
		if cmd == "/giveflux":
			Global.add_effect.emit("discombobulator")
		)
	
	Global.command_sent.emit("/resetdeco")
	Global.current_effects = []
	Save.data.story_point = "stewardship"
	Save.advance_story()
	
	Global.command_sent.emit("/enableattn")
	await get_tree().create_timer(0.2).timeout # race condition?
	Global.add_effect.emit("discombobulator")

func _process(delta: float) -> void:
	$PulleyMesh.rotation.y += delta * 2.1
