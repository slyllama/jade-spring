extends Node3D

var spiral_mat: ShaderMaterial

func set_shader_pos(val: float) -> void:
	spiral_mat.set_shader_parameter("h_position", val)

func _ready() -> void:
	visible = false
	spiral_mat = $Spiral/Spiral.get_active_material(0).duplicate()
	$Spiral/Spiral.set_surface_override_material(0, spiral_mat)
	
	$Model/Tree.libraries = $Model/Tree.libraries.duplicate()
	
	for _n in Utilities.get_all_children(self):
		if _n is MeshInstance3D: # disable all shadows
			_n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	$Model/Tree.set("parameters/proc_appear/active",
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	await get_tree().process_frame
	var spiral_tween = create_tween()
	spiral_tween.tween_method(set_shader_pos, 1.0, -1.0, 1.0)
	visible = true
