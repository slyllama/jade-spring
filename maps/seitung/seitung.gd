extends "res://lib/map/map.gd"

func _ready() -> void:
	super()
	$DragonvoidArc/AnimationPlayer.play("Wobble")
	$DragonvoidArc2/AnimationPlayer.play("Wobble")
	$DragonvoidArc3/AnimationPlayer.play("Wobble")

func _on_discombobulator_interacted() -> void:
	Global.add_effect.emit("discombobulator")
