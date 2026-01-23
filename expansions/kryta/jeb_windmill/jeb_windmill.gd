@tool
extends Decoration

func _ready() -> void:
	super()
	$Mesh/AnimationPlayer.play("spin")
