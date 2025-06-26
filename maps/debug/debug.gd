extends "res://lib/map/map.gd"

func _ready() -> void:
	super()
	$Portal/AnimationPlayer.play("spin")
	Global.hud.get_node("SidePanel").modulate.a = 1.0 # just for debug
	
	Global.command_sent.connect(func(cmd):
		if cmd == "/giveflux":
			Global.add_qty_effect("discombobulator_qty")
		elif "/maxfps=" in cmd:
			var _max_fps: int = int(cmd.split("=")[1])
			Engine.max_fps = _max_fps
		)
	
	Global.command_sent.emit("/resetdeco")
	Global.current_effects = []
	Save.data.story_point = "stewardship"
	Save.advance_story()
	
	Global.command_sent.emit("/enableattn")
	await get_tree().create_timer(0.2).timeout # race condition?
	
	$Otter/AnimationPlayer.speed_scale = 0.75
	$Otter/AnimationPlayer.animation_finished.connect(func(_anim):
		$Otter/AnimationPlayer.play("spin"))
	$Otter/AnimationPlayer.play("spin")
	
	var _m = load("res://lib/decoration/selection_icon.gd").new()
	add_child(_m)
	_m.position.y = 1.0

func _process(delta: float) -> void:
	$FishPool.rotation_degrees.y += delta * 4.0
