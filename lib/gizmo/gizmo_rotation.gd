@icon("res://lib/gizmo/icon_gizmo.svg")
class_name GizmoRotation extends Node3D

const RotatorMesh = preload("res://lib/gizmo/meshes/gizmo_rotation.glb")
const Dragger = preload("res://lib/dragger/dragger.tscn")

@export var is_global = false
@export var rotation_vector = Vector3(1, 0, 0)
@export var dragger_axis = "X"

var active = false
var enabled = false

var rotate_visual
var mat = ShaderMaterial.new()
var color: Color

func set_color(get_color: Color, dim = 0.5) -> void:
	color = get_color
	mat.set_shader_parameter("color", get_color * dim)

func _configure_grabber(grabber: StaticBody3D) -> void:
	grabber.mouse_entered.connect(func():
		if !enabled: return
		set_color(color, 1.0))
	grabber.mouse_exited.connect(func():
		if active: return
		set_color(color, 0.5))
	
	grabber.input_event.connect(func(_c, _e, _p, _n, _i):
		if Input.is_action_just_pressed("left_click"):
			var _d = Dragger.instantiate()
			if dragger_axis == "X":
				_d.axis = _d.Axis.X
			elif dragger_axis == "Y":
				_d.axis = _d.Axis.Y
			elif dragger_axis == "Z":
				_d.axis = _d.Axis.X
			add_child(_d)
			
			_d.ratio_changed.connect(func(ratio):
				if !is_global:
					get_parent().rotate_object_local(rotation_vector, ratio * 0.5)
				else:
					var _new_rotation = get_parent().global_rotation_degrees + ratio * 10.0 * rotation_vector
					get_parent().global_rotation_degrees = _new_rotation
			)
		)

func _configure_mesh(mesh: MeshInstance3D) -> void:
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.set_layer_mask_value(1, 0)
	mesh.set_layer_mask_value(2, 0)
	mesh.set_layer_mask_value(3, 1)
	mesh.set_surface_override_material(0, mat)

func destroy() -> void:
	enabled = false
	var scale_out_tween = create_tween()
	scale_out_tween.tween_property(
		rotate_visual, "scale", Vector3(0.01, 0.01, 0.01), 0.15)
	scale_out_tween.tween_callback(queue_free)

func _ready() -> void:
	enabled = true
	
	rotate_visual = RotatorMesh.instantiate()
	add_child(rotate_visual)
	if rotation_vector == Vector3(1, 0, 0):
		rotate_visual.rotation_degrees.z = 90
		rotate_visual.position.y += 0.05
	elif rotation_vector == Vector3(0, 0, 1):
		rotate_visual.rotation_degrees.x = 90
		rotate_visual.position.y += 0.05
	
	rotation_degrees = rotation_vector * Vector3(90, 90, 90)
	
	mat.shader = load("res://generic/materials/shaders/shader_color.gdshader")
	mat.render_priority = 3
	
	for _n in Utilities.get_all_children(rotate_visual):
		if _n is MeshInstance3D:
			_configure_mesh(_n)
		elif _n is StaticBody3D:
			_configure_grabber(_n)
	
	set_disable_scale(true)
	set_color(Color.WHITE)
	var scale_in_tween = create_tween()
	scale_in_tween.tween_property(rotate_visual, "scale", Vector3(1.5, 1.5, 1.5), 0.15)
	
	position.y = 1.0
