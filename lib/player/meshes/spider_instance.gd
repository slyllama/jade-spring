extends Node3D

# Get holographic material (should be the same for all the others)
@onready var holo_material: ShaderMaterial = $Armature/Skeleton3D/Cube_007/Cube_007.get_active_material(0)

func set_anim_speed(speed: float ) -> void:
	$Tree.set("parameters/time_scale/scale", speed)

func set_jump_scale(val: float) -> void:
	$Tree.set("parameters/jump_scale/add_amount", val)

func get_jump_scale() -> float:
	return($Tree.get("parameters/jump_scale/add_amount"))

func set_holo_exponent(val: float) -> void:
	val = ease(val, 2.0)
	var _e = 0.5 + (1 - val) * 15.5
	holo_material.set_shader_parameter("holo_exponent", _e)

func _ready() -> void:
	visible = false
	set_holo_exponent(0.0)
	
	Global.add_effect.connect(func(effect):
		if effect == "gravity":
			visible = true
			var _fade_in = create_tween()
			_fade_in.tween_method(set_holo_exponent, 0.0, 1.0, 0.5))
	Global.remove_effect.connect(func(effect):
		if effect == "gravity":
			var _fade_in = create_tween()
			_fade_in.tween_method(set_holo_exponent, 1.0, 0.0, 0.5)
			_fade_in.tween_callback(func():
				visible = false))
