extends "res://lib/map/map.gd"

func _ready() -> void:
	super()
	$DragonvoidArc/AnimationPlayer.play("Wobble")
	$DragonvoidArc2/AnimationPlayer.play("Wobble")
	$DragonvoidArc3/AnimationPlayer.play("Wobble")

func _on_discombobulator_interacted() -> void:
	Global.add_effect.emit("discombobulator")

func _on_bin_interacted() -> void:
	Save.data.deposited_weeds += Global.get_effect_qty("weed")
	Global.crumbs_updated.emit()
	Global.remove_effect.emit("weed")
