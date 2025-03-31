extends Node3D
# Weed bin

@export var karma_value = 5

func proc_story() -> void:
	var _p = Save.data.story_point
	if _p == "game_start":
		$Collision.visible = false
		$Collision.active = false
	else:
		$Collision.visible = true
		$Collision.active = true

func _ready() -> void:
	Save.story_advanced.connect(proc_story)
	proc_story()
	
	Global.summon_story_panel.connect(func(_data):
		if $Collision.overlaps_body(Global.player):
			Global.generic_area_left.emit())

func _on_bin_interacted() -> void:
	if Global.get_effect_qty("weed") > 0:
		$Foam.emitting = true
		$LeafSound.play()
		await get_tree().create_timer(0.3).timeout
		$Foam.emitting = false
	else: # do weed stuff
		Global.announcement_sent.emit(
			"This bin is hungry for some weeds and rotting shrubs.")
	
	Global.spawn_karma.emit(Global.get_effect_qty("weed") * Global.kv_weed, global_position)
	Save.data.deposited_weeds += Global.get_effect_qty("weed")
	
	Global.crumbs_updated.emit()
	Save.data.weeds = 0
	Global.remove_effect.emit("weed")

func _on_collision_body_entered(body: Node3D) -> void:
	if Save.data.story_point != "game_start" and Save.data.weeds > 0:
		Global.interact_hint = "Deposit Weeds"
