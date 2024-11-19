@icon("res://lib/gizmo/icon_gizmo.svg")
class_name GizmoScale extends Node3D

const ScaleMesh = preload("res://lib/gizmo/meshes/gizmo_scale.res")

var enabled = false
var active = false
var scale_visual = MeshInstance3D.new()
var grabber = PickBox.new()
var mat = ShaderMaterial.new()
var color: Color

func set_color(get_color: Color, dim = 0.5) -> void:
	color = get_color
	mat.set_shader_parameter("color", get_color * dim)

func _ready() -> void:
	enabled = true
	
	# Set up grabber from PickBox
	grabber.set_size(Vector3(0.8, 0.5, 0.5))
	grabber.make_ui_component()
	add_child(grabber)
	
	# Set up visible mesh
	scale_visual.mesh = ScaleMesh
	scale_visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	scale_visual.set_layer_mask_value(1, 0)
	scale_visual.set_layer_mask_value(2, 0)
	scale_visual.set_layer_mask_value(3, 1)
	#scale_visual.position.x = -0.45
	#scale_visual.rotation_degrees.y = -90 # correct visual orientation
	grabber.add_child(scale_visual)
	scale_visual.scale = Vector3(0.01, 0.01, 0.01)
	
	var scale_in_tween = create_tween()
	scale_in_tween.tween_property(scale_visual, "scale", Vector3(1.5, 1.5, 1.5), 0.15)
	
	mat.shader = load("res://generic/materials/shaders/shader_color.gdshader")
	mat.render_priority = 3
	scale_visual.set_surface_override_material(0, mat)
	set_color(Color.WHITE)
	
	grabber.mouse_entered.connect(func():
		if !enabled: return
		set_color(color, 1.0))
	grabber.mouse_exited.connect(func():
		if active: return
		set_color(color, 0.5))
	
	position.y = 2.5
