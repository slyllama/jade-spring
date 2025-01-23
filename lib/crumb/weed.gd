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
		if pickable and body is CharacterBody3D:
			Global.weed_crumb_entered.emit())
	
	body_exited.connect(func(body):
		if body is CharacterBody3D:
			Global.weed_crumb_left.emit())
	
	if !Engine.is_editor_hint():
		Save.story_advanced.connect(proc_story)
		proc_story()

func interact() -> void:
	if Save.data.story_point == "game_start":
		Global.announcement_sent.emit("Your air purifiers cower at the pungence of these rotting weeds.")
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
	
	await $Player.animation_finished
	clear()
