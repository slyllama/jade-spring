extends Node3D
const MESH = preload("res://lib/gizmo/meshes/gizmo_arrow.res")
const SHADER = preload("res://generic/materials/shaders/shader_color.gdshader")

var activated = false
var enabled = true
var color: Color
var axis := Vector3(1, 0, 0)
var drag_plane_scale := 5.0

var drag_box = Area3D.new()
var pick_box = Area3D.new()
var arrow_mesh = MeshInstance3D.new()
var mat = ShaderMaterial.new()

var last_pos := Vector3.ZERO
var last_click_pos := Vector3.ZERO

func enable() -> void:
	var scale_tween = create_tween()
	arrow_mesh.scale = Vector3(0.6, 0.6, 0.6)
	scale_tween.tween_property(
		arrow_mesh, "scale", Vector3(1.0, 1.0, 1.0), 0.3).set_ease(
			Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	enabled = true

func disable() -> void:
	deactivate()
	var scale_tween = create_tween()
	scale_tween.tween_property(
		arrow_mesh, "scale", Vector3(0.01, 0.01, 0.01), 0.3).set_ease(
			Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	enabled = false

func set_axis(get_axis: Vector3) -> void:
	axis = get_axis

func set_color(get_color: Color, dim = 0.5) -> void:
	color = get_color
	mat.set_shader_parameter("color", get_color * dim)

func activate() -> void:
	if !enabled: return
	last_pos = get_parent().position
	
	activated = true
	pick_box.input_ray_pickable = false
	drag_box.set_collision_layer_value(2, 1)

func deactivate() -> void:
	activated = false
	pick_box.input_ray_pickable = true
	drag_box.set_collision_layer_value(2, 0)
	
	set_color(color, 0.5)
	Global.mouse_in_ui = false

func _init() -> void:
	# Configure the arrow mesh, including making the mesh and shader unique
	# so that color changes will be individual
	arrow_mesh.mesh = MESH.duplicate()
	mat.shader = SHADER.duplicate()
	arrow_mesh.mesh.surface_set_material(0, mat)
	arrow_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _ready() -> void:
	add_child(arrow_mesh)
	
	# Generate the picking box used to select the gizmo axis
	var pick_coll = CollisionShape3D.new()
	var pick_shape = BoxShape3D.new()
	
	pick_shape.size = Vector3(0.2, 0.2, 0.5)
	pick_coll.position.z = -0.4
	pick_coll.shape = pick_shape
	pick_box.add_child(pick_coll)
	add_child(pick_box)
	
	pick_box.mouse_entered.connect(func():
		if !enabled: return
		set_color(color, 1.0)
		Global.mouse_in_ui = true)
	pick_box.mouse_exited.connect(func():
		if !activated:
			set_color(color, 0.5)
			Global.mouse_in_ui = false)
	
	pick_box.input_event.connect(func(_c, _e, _p, _n, _i):
		if Input.is_action_just_pressed("left_click"):
			activate())
	
	var drag_coll = CollisionShape3D.new()
	var drag_shape = BoxShape3D.new()
	
	drag_shape.size = Vector3(drag_plane_scale, 0.05, drag_plane_scale)
	drag_coll.shape = drag_shape
	drag_box.add_child(drag_coll)
	drag_box.set_collision_layer_value(1, 0)
	add_child(drag_box)

func _input(_event: InputEvent) -> void:
	if !activated: return
	if Input.is_action_just_released("left_click"):
		deactivate()

func _process(delta: float) -> void:
	if !enabled or !activated: return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = Global.camera.project_ray_origin(mouse_pos)
	var to = from + Global.camera.project_ray_normal(mouse_pos) * 200
	var space_state = get_world_3d().direct_space_state
	
	var mesh_query = PhysicsRayQueryParameters3D.create(from, to)
	mesh_query.collide_with_areas = true
	mesh_query.collide_with_bodies = false
	mesh_query.collision_mask = 0b0010
	
	var intersect = space_state.intersect_ray(mesh_query)
	if intersect != {}:
		if Input.is_action_just_pressed("left_click"):
			last_click_pos = intersect.position
		get_parent().position = lerp(get_parent().position, last_pos + (
			intersect.position - last_click_pos) * axis, 14 * delta)
