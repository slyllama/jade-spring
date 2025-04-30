@icon("res://lib/gizmo/icon_gizmo.svg")
class_name GizmoRotation extends Node3D

const RotatorMesh = preload("res://lib/gizmo/meshes/gizmo_rotation.glb")
const Dragger = preload("res://lib/dragger/dragger.tscn")

@export var is_global = false
@export var rotation_vector = Vector3(1, 0, 0)
@export var dragger_axis = "X"

var active = false
var enabled = false
var mouse_down = false

var rotate_visual: Node3D
var axis_stick = CSGBox3D.new()
var tick_sound = AudioStreamPlayer.new()

var mat = ShaderMaterial.new()
var color: Color
var accumulated_ratio = 0.0

signal mouse_entered

func set_color(get_color: Color, dim = 0.5) -> void:
	color = get_color
	mat.set_shader_parameter("color", get_color * dim)

func _configure_grabber(grabber: Area3D) -> void:
	grabber.mouse_entered.connect(func():
		if !enabled: return
		mouse_entered.emit()
		set_color(color, 1.0))
	grabber.mouse_exited.connect(func():
		if active: return
		set_color(color, 0.5))
	
	grabber.input_event.connect(func(_c, _e, _p, _n, _i):
		if Input.is_action_just_pressed("left_click") and get_parent().last_rotator == self:
			if mouse_down: 
				print("[GizmoRotation] rejecting duplicate.")
				return
			mouse_down = true # prevent duplicates
			var _d = Dragger.instantiate()
			if dragger_axis == "X":
				_d.axis = _d.Axis.X
			elif dragger_axis == "Y":
				_d.axis = _d.Axis.Y
			elif dragger_axis == "Z":
				_d.axis = _d.Axis.X
			add_child(_d)
			
			axis_stick.visible = true
			var scale_tween = create_tween()
			scale_tween.tween_property(
				rotate_visual, "scale", Vector3(2.6, 2.6, 2.6), 0.1)
			
			_d.destroyed.connect(func():
				axis_stick.visible = false
				var scale_out_tween = create_tween()
				scale_out_tween.tween_property(
					rotate_visual, "scale", Vector3(1.5, 1.5, 1.5), 0.1))
			
			_d.ratio_changed.connect(func(ratio):
				var _r = ratio # invert rotation for one axis (feels better)
				accumulated_ratio += _r
				if _d.axis == _d.Axis.Y:
					_r = -ratio
				
				if !is_global:
					if Global.snapping:
						if accumulated_ratio > 5.0:
							tick_sound.play()
							get_parent().rotate_object_local(
								rotation_vector, deg_to_rad(22.5))
							accumulated_ratio = 0.0
						elif accumulated_ratio < -5.0:
							tick_sound.play()
							get_parent().rotate_object_local(
								rotation_vector, -deg_to_rad(22.5))
							accumulated_ratio = 0.0
					else:
						get_parent().rotate_object_local(
							rotation_vector, _r * 0.1)
				else:
					var _new_rotation = get_parent().global_rotation_degrees + _r * 10.0 * rotation_vector
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

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("left_click") and enabled:
		mouse_down = false

func _ready() -> void:
	enabled = true
	rotate_visual = RotatorMesh.instantiate()
	add_child(rotate_visual)
	
	add_child(tick_sound)
	tick_sound.set_stream(load("res://generic/sounds/tick.ogg"))
	tick_sound.volume_db = 12.0
	
	# Replace the imported StaticBody3D with an Area3D
	# (Could've instanced the important scene but whatever, LMAO)
	var _area = Area3D.new()
	_area.add_child(rotate_visual.get_node("Collision/CollisionShape3D").duplicate(true))
	_area.set_collision_layer_value(1, false)
	_area.set_collision_layer_value(5, true)
	_area.set_collision_mask_value(1, false)
	_area.set_collision_mask_value(5, true)
	rotate_visual.get_node("Collision").queue_free()
	rotate_visual.add_child(_area)
	
	axis_stick.size = Vector3(0.01, 50.0, 0.01)
	axis_stick.material_override = mat
	rotate_visual.add_child(axis_stick)
	axis_stick.visible = false
	
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
		elif _n is Area3D:
			_configure_grabber(_n)
	
	set_disable_scale(true)
	set_color(Color.WHITE)
	var scale_in_tween = create_tween()
	scale_in_tween.tween_property(rotate_visual, "scale", Vector3(1.5, 1.5, 1.5), 0.15)
	
	#position.y = 1.0
