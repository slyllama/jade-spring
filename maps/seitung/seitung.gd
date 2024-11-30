extends "res://lib/map/map.gd"

func _ready() -> void:
	super()
	$DragonvoidArc/AnimationPlayer.play("Wobble")
	$DragonvoidArc2/AnimationPlayer.play("Wobble")
