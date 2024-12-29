extends "res://lib/map/map.gd"

const Dialogue = preload("res://lib/dialogue/dialogue.tscn")

func set_marker_pos() -> void: # set the position of the story marker
	match Save.data.story_point:
		"game_start": $StoryMarker.position = $Decoration/Foliage/Pulley.position
		"pick_weeds": $StoryMarker.position = $WeedBin.position
		"clear_bugs": $StoryMarker.position = $Discombobulator.position + Vector3(-0.5, 0, 0)
		"_": $StoryMarker.position = Vector3(0, -10, 0) # hide under map

func _ready() -> void:
	super()
	
	Save.story_advanced.connect(set_marker_pos)
	await get_tree().process_frame
	set_marker_pos()
	
	$DragonvoidArc/AnimationPlayer.play("Wobble")
	$DragonvoidArc2/AnimationPlayer.play("Wobble")
	$DragonvoidArc3/AnimationPlayer.play("Wobble")

func _on_discombobulator_interacted() -> void:
	Global.add_effect.emit("discombobulator")

func _on_bin_interacted() -> void:
	if Global.get_effect_qty("weed") > 0:
		$WeedBin/Foam.emitting = true
		$WeedBin/LeafSound.play()
		await get_tree().create_timer(0.3).timeout
		$WeedBin/Foam.emitting = false
	else: # do weed stuff
		Global.announcement_sent.emit("((Comment about no weeds))")
	Save.data.deposited_weeds += Global.get_effect_qty("weed")
	Global.crumbs_updated.emit()
	Save.data.weeds = 0
	Global.remove_effect.emit("weed")

func _on_dialogue_test_interacted() -> void:
	var _d = Dialogue.instantiate()
	add_child(_d)
	_d.open()
