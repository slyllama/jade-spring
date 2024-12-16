extends "res://lib/map/map.gd"

func _ready() -> void:
	super()
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
	else:
		Global.announcement_sent.emit("((Comment about no weeds))")
		pass # do weed stuff
	Save.data.deposited_weeds += Global.get_effect_qty("weed")
	Global.crumbs_updated.emit()
	Save.data.weeds = 0
	Global.remove_effect.emit("weed")
