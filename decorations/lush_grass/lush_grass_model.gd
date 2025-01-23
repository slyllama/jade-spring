extends Node3D

var mat: ShaderMaterial

func _ready() -> void:
	var _mesh: Mesh = $FoliageSpawner.multimesh.mesh
	mat = _mesh.surface_get_material(0)
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/time=night":
			#mat.set_shader_parameter("backlight", 0.2)
			mat.set_shader_parameter("alpha_scissor_threshold", 0.31)
			mat.set_shader_parameter("albedo", Color(0.9, 0.9, 0.9))
		elif _cmd == "/time=day":
			#mat.set_shader_parameter("backlight", 0.6)
			mat.set_shader_parameter("alpha_scissor_threshold", 0.21)
			mat.set_shader_parameter("albedo", Color.WHITE)
	)
