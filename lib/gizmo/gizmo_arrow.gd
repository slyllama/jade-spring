@icon("res://lib/gizmo/icon_gizmo.svg")
class_name GizmoArrow extends Node3D

const ArrowMesh = preload("res://lib/gizmo/meshes/gizmo_arrow.res")
const EXTENTS = 30.0

var enabled = false
var active = false
var color: Color
var single_axis = true
var initial_rotation = Vector3.ZERO
var initial_override_rotation = null

var grabber = PickBox.new()
var arrow_visual = MeshInstance3D.new()
var drag_plane = PickBox.new()
var adjacent_plane = PickBox.new()
var tangent_cast = RayCast3D.new()
var mat = ShaderMaterial.new()

func set_color(get_color: Color, dim = 0.5) -> void:
	color = get_color
	mat.set_shader_parameter("color", get_color * dim)

func get_drag_collision():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = Global.camera.project_ray_origin(mouse_pos)
	var to = from + Global.camera.project_ray_normal(mouse_pos) * 200
	var space_state = get_world_3d().direct_space_state
	var mesh_query = PhysicsRayQueryParameters3D.create(from, to)
	
	mesh_query.collide_with_areas = true
	mesh_query.collide_with_bodies = false
	mesh_query.collision_mask = 0b0010
	
	var intersect = space_state.intersect_ray(mesh_query)
	if intersect != {}: return(intersect.position)
	else: return(null)

func destroy() -> void:
	enabled = false
	var scale_out_tween = create_tween()
	scale_out_tween.tween_property(arrow_visual, "scale", Vector3(0.01, 0.01, 0.01), 0.15)
	scale_out_tween.tween_callback(queue_free)

func _ready() -> void:
	enabled = true
	rotation_degrees += initial_rotation
	if initial_override_rotation != null:
		global_rotation_degrees = initial_override_rotation
	
	grabber.set_size(Vector3(0.8, 0.5, 0.5))
	grabber.make_ui_component()
	grabber.position.x = 0.45
	add_child(grabber)
	
	# Visual arrow display
	arrow_visual.mesh = ArrowMesh
	arrow_visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arrow_visual.set_layer_mask_value(1, 0)
	arrow_visual.set_layer_mask_value(2, 0)
	arrow_visual.set_layer_mask_value(3, 1)
	arrow_visual.position.x = -0.45
	arrow_visual.rotation_degrees.y = -90 # correct visual orientation
	grabber.add_child(arrow_visual)
	arrow_visual.scale = Vector3(0.01, 0.01, 0.01)
	
	var scale_in_tween = create_tween()
	scale_in_tween.tween_property(arrow_visual, "scale", Vector3(1.35, 1.35, 1.35), 0.15)
	
	mat.shader = load("res://generic/materials/shaders/shader_color.gdshader")
	mat.render_priority = 3
	arrow_visual.set_surface_override_material(0, mat)
	
	grabber.mouse_entered.connect(func():
		if !enabled: return
		set_color(color, 1.0))
	grabber.mouse_exited.connect(func():
		if active: return
		set_color(color, 0.5))
	
	grabber.drag_started.connect(func():
		if !enabled: return
		tangent_cast.visible = true
		drag_plane.set_collision_layer_value(2, 1)
		adjacent_plane.set_collision_layer_value(3, 1)
		active = true)
	
	grabber.drag_ended.connect(func():
		tangent_cast.visible = false
		drag_plane.set_collision_layer_value(2, 0)
		adjacent_plane.set_collision_layer_value(3, 0)
		set_color(color, 1.0)
		active = false)
	
	drag_plane.input_ray_pickable = false
	drag_plane.set_collision_layer_value(1, 0)
	drag_plane.set_collision_layer_value(2, 0)
	drag_plane.set_size(Vector3(EXTENTS, 0.01, EXTENTS))
	grabber.add_child(drag_plane)
	
	adjacent_plane.input_ray_pickable = false
	adjacent_plane.set_collision_layer_value(1, 0)
	adjacent_plane.set_collision_layer_value(3, 0)
	adjacent_plane.set_size(Vector3(0.2, 0.01, EXTENTS))
	grabber.add_child(adjacent_plane)
	adjacent_plane.rotation_degrees = Vector3(0, 90, 90)
	
	# Set planes top-level
	drag_plane.position.y += 1
	drag_plane.top_level = true
	adjacent_plane.position.y += 1
	adjacent_plane.top_level = true
	
	add_child(tangent_cast)
	tangent_cast.visible = false
	tangent_cast.set_collision_mask_value(1, 0)
	tangent_cast.set_collision_mask_value(2, 0)
	tangent_cast.set_collision_mask_value(3, 1)
	tangent_cast.collide_with_areas = true
	tangent_cast.target_position = Vector3(0, 0, EXTENTS)
	tangent_cast.top_level = true
	
	position.y = 1.0
	set_disable_scale(true)

var last_collision = null
@onready var last_position = get_parent().global_position

func _process(delta: float) -> void:
	if !enabled: return
	
	adjacent_plane.global_position = global_position
	drag_plane.global_position = global_position
	
	if !active or !get_drag_collision(): return
	tangent_cast.global_position = get_drag_collision()
	tangent_cast.global_rotation = global_rotation
	tangent_cast.global_position -= EXTENTS / 2 * global_transform.basis.z
	
	if active and get_drag_collision() != null:
		if tangent_cast.get_collider() != null:
			if last_collision == null:
				last_position = get_parent().global_position
				if single_axis:
					last_collision = tangent_cast.get_collision_point()
				else: last_collision = get_drag_collision()
			else:
				var _new_pos
				if single_axis: _new_pos = last_position + tangent_cast.get_collision_point() - last_collision
				else: _new_pos = last_position + get_drag_collision() - last_collision
				get_parent().global_position = lerp(get_parent().global_position, _new_pos, 14 * delta)
		else:
			drag_plane.global_position = global_position
			last_collision = null
