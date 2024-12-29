extends Node3D
# Weed bin

func _on_bin_interacted() -> void:
	if Global.get_effect_qty("weed") > 0:
		$Foam.emitting = true
		$LeafSound.play()
		await get_tree().create_timer(0.3).timeout
		$Foam.emitting = false
	else: # do weed stuff
		Global.announcement_sent.emit("This bin is hungry for some weeds and rotting shrubs.")
	Save.data.deposited_weeds += Global.get_effect_qty("weed")
	Global.crumbs_updated.emit()
	Save.data.weeds = 0
	Global.remove_effect.emit("weed")
