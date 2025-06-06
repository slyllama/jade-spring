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
	holo_material.set_shader_parameter("alpha", val)

func _input(_event: InputEvent) -> void:
	if !Global.debug_allowed: return
	if Input.is_action_just_pressed("debug_action"):
		if "gravity" in Global.current_effects:
			if visible: visible = false
			else: visible = true

func _ready() -> void:
	visible = false
	holo_material.set_shader_parameter("use_alpha", true)
	set_holo_exponent(0.0)
	
	Global.add_effect.connect(func(effect):
		if effect == "gravity":
			if get_parent().get_node("PlayerMesh").visible:
				visible = true # don't make visible if the player has hidden
			var _fade_in = create_tween()
			_fade_in.tween_method(set_holo_exponent, 0.0, 1.0, 0.5))
	Global.remove_effect.connect(func(effect):
		if effect == "gravity":
			var _fade_in = create_tween()
			_fade_in.tween_method(set_holo_exponent, 1.0, 0.0, 0.5)
			_fade_in.tween_callback(func():
				visible = false))
