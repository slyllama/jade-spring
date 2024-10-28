class_name Cursor3D extends Node3D

const DECAL_TEXTURE = preload("res://lib/cursor_3d/textures/cursor_decal.png")
var cursor_decal = Decal.new() # will be able to change this

func set_cursor_tint(color: Color):
	cursor_decal.modulate = color

func _ready() -> void:
	cursor_decal.texture_albedo = DECAL_TEXTURE
	cursor_decal.normal_fade = 0.99
	cursor_decal.cull_mask = 1 # don't paint grass!
	cursor_decal.size.y = 5.0
	add_child(cursor_decal)
	
	Global.cursor_disabled.connect(queue_free)
	Global.cursor_tint_changed.connect(set_cursor_tint)

func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = Global.camera.project_ray_origin(mouse_pos)
	var to = from + Global.camera.project_ray_normal(mouse_pos) * 200
	var space_state = get_world_3d().direct_space_state
	
	var mesh_query = PhysicsRayQueryParameters3D.create(from, to)
	mesh_query.collision_mask = 10
	mesh_query.collide_with_areas = true
	mesh_query.collide_with_bodies = true
	
	var intersect = space_state.intersect_ray(mesh_query)
	if intersect != {}:
		if !visible:
			visible = true
		position = intersect.position
		#rotation = intersect.normal
	else:
		if visible:
			visible = false
