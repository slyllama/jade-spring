@tool
extends Crumb

var rng = RandomNumberGenerator.new()
var pickable = true

func _ready() -> void:
	super()
	$Foam.emitting = false
	body_entered.connect(func(body):
		if pickable and body is CharacterBody3D:
			Global.weed_crumb_entered.emit())
	
	body_exited.connect(func(body):
		if body is CharacterBody3D:
			Global.weed_crumb_left.emit())

func interact() -> void:
	if Save.data.story_point == "game_start":
		Global.announcement_sent.emit("((Comment about weeds))")
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
