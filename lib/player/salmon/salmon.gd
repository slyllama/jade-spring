@tool
extends Node3D

func _ready() -> void:
	$SalmonMesh/AnimationPlayer.play("flop")
