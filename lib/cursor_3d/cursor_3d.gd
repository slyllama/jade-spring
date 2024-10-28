class_name Cursor3D extends Node3D

var cursor_mesh = MeshInstance3D.new() # will be able to change this

func set_cursor_tint(color: Color):
	cursor_mesh.mesh.surface_get_material(0).albedo_color = color

func _ready() -> void:
	var mat_color = StandardMaterial3D.new()
	mat_color.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	cursor_mesh.transparency = 0.6
	cursor_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	cursor_mesh.mesh = SphereMesh.new()
	cursor_mesh.mesh.surface_set_material(0, mat_color)
	add_child(cursor_mesh)
	set_cursor_tint(Color.RED)
	
	Global.cursor_disabled.connect(queue_free)
	Global.cursor_tint_changed.connect(set_cursor_tint)

func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = Global.camera.project_ray_origin(mouse_pos)
	var to = from + Global.camera.project_ray_normal(mouse_pos) * 200
	var space_state = get_world_3d().direct_space_state
	
	var mesh_query = PhysicsRayQueryParameters3D.create(from, to)
	mesh_query.collide_with_areas = true
	mesh_query.collide_with_bodies = true
	
	var intersect = space_state.intersect_ray(mesh_query)
	if intersect != {}:
		if !visible:
			visible = true
		position = intersect.position
	else:
		if visible:
			visible = false
