class_name Cursor3D extends Node3D

const CursorSphere = preload("res://lib/cursor_3d/meshes/cursor_sphere.glb")

var current_radius := 1.0
var cursor_sphere: Node3D = CursorSphere.instantiate()
var cursor_area := CursorArea.new()
var highlight_on_decoration := true
var y_rotation := 0.0 # this will be added to the rotation
var disabled = false
var data = {}

func set_cursor_tint(color: Color):
	if disabled or !highlight_on_decoration: return
	for _n in Utilities.get_all_children(cursor_sphere):
		if _n is MeshInstance3D:
			_n.get_active_material(0).set_shader_parameter("albedo", color)

func set_radius(radius: float) -> void:
	current_radius = radius
	cursor_area.shape.radius = radius
	cursor_sphere.scale = Vector3(2, 2, 2) * radius

#region Activate/Deactivate
func activate(get_data: Dictionary) -> void:
	data = get_data
	set_cursor_tint(Color.RED)
	if "highlight_on_decoration" in data:
		highlight_on_decoration = data.highlight_on_decoration
	if "radius" in data:
		set_radius(data.radius)
	else:
		set_radius(0.47)
	
	# Cursor tint and radius is ignored if a custom model is used
	if "custom_model" in data:
		var xray = XRayMesh.new()
		var model = data.custom_model.instantiate()
		xray.add_child(model)
		add_child(xray)
		if "y_rotation" in data:
			y_rotation = data.y_rotation
	else:
		for _n in Utilities.get_all_children(cursor_sphere):
			if _n is MeshInstance3D:
				var _m = _n.get_active_material(0).duplicate()
				_n.set_surface_override_material(0, _m)
		
		add_child(cursor_area)
		add_child(cursor_sphere)
		Global.cursor_tint_changed.connect(set_cursor_tint)
	
	# Animate the cursor in
	cursor_sphere.scale = Vector3(0.01, 0.01, 0.01)
	var scale_tween = create_tween()
	scale_tween.tween_property(
		cursor_sphere, "scale", Vector3(2, 2, 2) * current_radius, 0.1)

# Remove cursor
func dismiss() -> void:
	# Animate the cursor out and destroy it when it is dismissed
	disabled = true
	Global.mouse_3d_position = Utilities.BIGVEC3
	var scale_out_tween = create_tween()
	scale_out_tween.tween_property(
		cursor_sphere, "scale", Vector3(0.01, 0.01, 0.01), 0.12)
	scale_out_tween.tween_callback(queue_free)
#endregion

func _input(_event: InputEvent) -> void:
	if Global.mouse_in_ui: return
	if Global.camera_orbiting: return
	# Emit the 3D cursor click signal if its position is valid
	
	if Input.is_action_just_released("left_click"):
		if Global.deco_button_pressed: return
		if Global.mouse_3d_position != Utilities.BIGVEC3:
			Global.mouse_3d_click.emit()
			visible = false
	
	if Input.is_action_just_pressed("left_click"):
		if Global.deco_button_pressed:
			Global.deco_button_pressed = false

func _ready() -> void:
	Global.cursor_disabled.connect(dismiss)
	# Make sure to call activate() after the node is ready!

var _target_normal = Vector3.ZERO

func _process(_delta: float) -> void:
	if disabled: return
	
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
		Global.mouse_3d_position = intersect.position
		_target_normal = intersect.normal
	else:
		Global.mouse_3d_position = Utilities.BIGVEC3 # set an impossible position
		if visible:
			visible = false
	
	# Hide the cursor while panning with the mouse
	if visible and Global.camera_orbiting: visible = false
	if !visible and !Global.camera_orbiting: visible = true
	
	if Global.mouse_in_ui: visible = false
	
	# Get the facing angle (y-axis) from the player to the 3D cursor
	var _a := Vector2(Global.player_position.x, Global.player_position.z)
	var _b := Vector2(Global.mouse_3d_position.x, Global.mouse_3d_position.z)
	
	# TODO: currently disabled camera orientation-bases rotation. We might
	# bring this back in the future but it's feeling more sensible like this
	# for the moment.
	
	if "custom_model" in data:
		global_rotation.y = data.y_rotation
		Global.mouse_3d_y_rotation = rotation.y
	
	#if !"custom_model" in data:
		#rotation = lerp(rotation, _target_normal, delta * 3)
	#else:
		#global_rotation.y = (_b.angle_to_point(_a)
			#+ (Global.camera.global_rotation.y * 2.0) - deg_to_rad(90))
		#if "y_rotation" in data:
			#global_rotation.y += deg_to_rad(data.y_rotation)
		#Global.mouse_3d_y_rotation = rotation.y
