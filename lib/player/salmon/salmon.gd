@tool
extends Node3D

func _ready() -> void:
	$SalmonMesh/AnimationPlayer.animation_finished.connect(func(_anim):
		$SalmonMesh/AnimationPlayer.play("flop"))
	$SalmonMesh/AnimationPlayer.play("flop")
