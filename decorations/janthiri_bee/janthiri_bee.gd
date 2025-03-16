@tool
extends Node3D

var rng = RandomNumberGenerator.new()

func _ready():
	$AnimationPlayer.play("idle2")
	$AnimationPlayer.speed_scale = 0.8 + rng.randf() * 0.2
	$AnimationPlayer.seek(rng.randf_range(0.0, 1.0))
