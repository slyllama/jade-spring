extends Node3D

func set_anim_speed(speed: float ) -> void:
	$Tree.set("parameters/time_scale/scale", speed)

func set_jump_scale(val: float) -> void:
	$Tree.set("parameters/jump_scale/add_amount", val)

func get_jump_scale() -> float:
	return($Tree.get("parameters/jump_scale/add_amount"))
