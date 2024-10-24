@tool
class_name MMOCamera extends Node3D
const MMOOrbitHandler = preload("res://addons/mmo_camera/orbit_handler.gd")

@export var orbit_disabled := false
@export var orbit_sensitivity := 0.15
@export var orbit_smoothing := 12.0
@export_range(-180, 180, 0.1, "degrees", "hide_slider") var fov := 85.0
@export_range(0, 100, 0.01, "suffix:m", "hide_slider") var zoom_increment = 0.25
@export_range(0, 100, 0.1, "suffix:m", "hide_slider") var max_zoom_in = 0.5
@export_range(0, 100, 0.1, "suffix:m", "hide_slider") var max_zoom_out = 1.5
@export_range(0, 100, 0.1, "suffix:m", "hide_slider") var v_offset = 0.4

@export var ignore_exclusive_ui := false
@export var excluded_collision_objects: Array[PhysicsBody3D]

@export_category("Clamping")
@export var clamp_x := true
@export_range(-180, 180, 0.1, "degrees", "hide_slider") var clamp_x_lower := -65.0
@export_range(-180, 180, 0.1, "degrees", "hide_slider")  var clamp_x_upper := 10.0
@export var clamp_y := false
@export_range(-180, 180, 0.1, "degrees", "hide_slider")  var clamp_y_lower := -180.0
@export_range(-180, 180, 0.1, "degrees", "hide_slider")  var clamp_y_upper := 180.0

@export_category("Input Binding")
@export var left_click := "left_click"
@export var zoom_in := "zoom_in"
@export var zoom_out := "zoom_out"

var in_exclusive_ui = false
var mouse_in_ui = false
var calculated_sensitivity = orbit_sensitivity

var _target_zoom = max_zoom_in + 0.5 * (max_zoom_out - max_zoom_in)

var axis = SpringArm3D.new()
var camera = Camera3D.new()
var orbit_handler = MMOOrbitHandler.new()
var target = Node3D.new()

# Adapt the v_offset of the camera to the zoom level
func _get_v_offset() -> float:
	return((_target_zoom - max_zoom_in) / (max_zoom_out - max_zoom_in) * v_offset)

func _input(event: InputEvent) -> void:
	if event is InputEventPanGesture: _target_zoom += event.delta.y / 2.0
	if Input.is_action_just_pressed(zoom_in): _target_zoom -= zoom_increment
	if Input.is_action_just_pressed(zoom_out): _target_zoom += zoom_increment

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	# Configure camera and spring arm
	axis.spring_length = 4.0
	axis.margin = 0.5
	camera.fov = fov
	
	# Add components to the scene
	add_child(axis)
	add_child(camera)
	add_child(orbit_handler)
	axis.add_child(target)
	
	for _n in excluded_collision_objects:
		axis.add_excluded_object(_n)
	
	# Set up initial characteristics
	axis.spring_length = _target_zoom
	target.position.z = axis.position.z + _target_zoom
	camera.position = target.position * 1.5
	camera.v_offset = _get_v_offset()
	#orbit_handler.set_initial_rotation(rotation_degrees + Vector3(-30, 45, 0,))

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_target_zoom = clamp(_target_zoom, max_zoom_in, max_zoom_out)
	
	var _spring_ratio = axis.get_hit_length() / axis.spring_length
	var _target_v_offset = _get_v_offset() * _spring_ratio
	var _v_offset = lerp(camera.v_offset, _target_v_offset, 6 * delta)
	camera.v_offset = _v_offset
	
	# Apply camera transformations
	axis.spring_length = lerp(axis.spring_length, _target_zoom, 6.0 * delta)
	camera.position = lerp(camera.position, target.position, 6.0 * delta)
	rotation_degrees = orbit_handler.smooth_rotation
	#camera.v_offset = _target_v_offset
