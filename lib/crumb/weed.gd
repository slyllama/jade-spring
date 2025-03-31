@tool
extends Crumb

var rng = RandomNumberGenerator.new()
var pickable = true

func proc_story() -> void:
	var _p = Save.data.story_point
	if _p == "game_start":
		$VisualArea.visible = false
	else:
		$VisualArea.visible = true

func _ready() -> void:
	super()
	
	# Make a bit more organic-feeling
	$WeedMesh.rotation_degrees.y = rng.randf() * 360.0
	$WeedMesh.rotation_degrees.x = rng.randf() * 10.0 - 5.0
	$WeedMesh.rotation_degrees.z = rng.randf() * 10.0 - 5.0
	var _scale_factor = rng.randf_range(1.0, 1.3)
	$WeedMesh.scale *= _scale_factor
	$Foam.emitting = false
	
	body_entered.connect(func(body):
		if Global.story_panel_open: return
		if pickable and body is CharacterBody3D:
			Global.weed_crumb_entered.emit())
	
	body_exited.connect(func(body):
		if Global.story_panel_open: return
		if body is CharacterBody3D:
			Global.weed_crumb_left.emit())
	
	if !Engine.is_editor_hint():
		Save.story_advanced.connect(proc_story)
		proc_story()
		
		Global.weed_crumb_entered.connect(func():
			if Save.data.story_point != "game_start":
				Global.interact_hint = "Pick Weed")
		
		Global.summon_story_panel.connect(func(_data):
			if pickable and overlaps_body(Global.player):
				Global.weed_crumb_left.emit())
		
		Global.close_story_panel.connect(func():
			if pickable and overlaps_body(Global.player):
				Global.weed_crumb_entered.emit())

func interact() -> void:
	if Save.data.story_point == "game_start":
		Global.announcement_sent.emit("My air purifiers are withering at the stink of these rotting weeds!")
		Global.weed_crumb_left.emit()
		return
	
	if !pickable: return
	pickable = false
	Global.add_qty_effect("weed")
	Global.weed_crumb_left.emit()
	var _pitch = rng.randf_range(0.9, 1.1)
	$LeafSound.pitch_scale = _pitch
	$LeafSound.play()
	$Player.play("clear")
	
	Global.play_hint("picked_weeds", { 
				"title": "Picked Weeds",
				"arrow": "down",
				"anchor_preset": Control.LayoutPreset.PRESET_CENTER_BOTTOM,
				"text": "Weeds that you have picked (along with any other effects and items) will appear here."
			}, Utilities.get_screen_center(Vector2(0, get_viewport().size.y / Global.retina_scale * 0.5 - 300)), true)
	
	await $Player.animation_finished
	clear()
