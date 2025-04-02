@tool
class_name XRayMesh extends Node3D
# XRayMesh
# Replaces the material of all its child meshes with an x-ray material

const XRAY_MAT = preload("res://lib/xray_mesh/materials/mat_xray.tres")

func _get_all_children(node: Node) -> Array:
	var nodes: Array = []
	if !node: return([])
	for n in node.get_children():
		if n.get_child_count() > 0:
			nodes.append(n)
			nodes.append_array(_get_all_children(n, ))
		else: nodes.append(n)
	return(nodes)

func _ready() -> void:
	for _n in _get_all_children(self):
		if _n is MeshInstance3D:
			for _m in _n.get_surface_override_material_count():
				if !_n.get_active_material(_m):
					continue
				var _original_material = _n.get_active_material(_m)
				var _xray_mat = XRAY_MAT.duplicate()
				if "albedo_texture" in _original_material:
					var _alpha_mask = _original_material.albedo_texture
					_xray_mat.set_shader_parameter("alpha_mask", _alpha_mask)
				elif "shader_parameter/texture_albedo" in _original_material:
					var _alpha_mask = _original_material.get_shader_parameter("texture_albedo")
					_xray_mat.set_shader_parameter("alpha_mask", _alpha_mask)
				_n.set_surface_override_material(_m, _xray_mat)
				_n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
