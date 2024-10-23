@tool
extends Node
# OrbitHandler
# Handles getting mouse drag events for orbiting

var orbiting = false
var target_rotation = Vector3.ZERO
var smooth_rotation = Vector3.ZERO

var _mouse_delta = Vector2.ZERO # event.relative
var _last_click_position = Vector2.ZERO
# If a click and drag is initiated in the map, the drag will not influence camera
# orbiting until release
var _clicked_in_ui = false

func set_initial_rotation(rotation: Vector3) -> void:
	target_rotation = rotation
	smooth_rotation = rotation

func _ready() -> void:
	if Engine.is_editor_hint(): return
	get_window().focus_exited.connect(func():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		orbiting = false)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	
	if Input.is_action_just_pressed(get_parent().left_click):
		if get_parent().orbit_disabled: return
		if get_parent().mouse_in_ui:
			_clicked_in_ui = true
		else:
			get_viewport().gui_release_focus()
		_last_click_position = get_window().get_mouse_position()
	if Input.is_action_just_released(get_parent().left_click):
		_clicked_in_ui = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		orbiting = false
	
	if event is InputEventMouseMotion:
		_mouse_delta = event.relative

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if get_parent().orbit_disabled: return
	if get_parent().in_exclusive_ui and !get_parent().ignore_exclusive_ui:
		return
	
	# Only enter orbit mode after dragging the screen a certain amount i.e., not instantly
	if (!orbiting and !_clicked_in_ui and Input.is_action_pressed(get_parent().left_click)):
		var _mouse_offset = get_window().get_mouse_position() - _last_click_position
		if abs(_mouse_offset.x) > 5 or abs(_mouse_offset.y) > 5:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			orbiting = true
	
	# Process relative mouse movement (_mouse_delta)
	# This is handled here instead of _input() because handling without delta
	# causes strange behaviour at low frame rates
	if orbiting:
		target_rotation.x -= _mouse_delta.y * get_parent().calculated_sensitivity * delta * 100.0
		if get_parent().clamp_x: target_rotation.x = clamp(
			target_rotation.x, get_parent().clamp_x_lower, get_parent().clamp_x_upper)
		target_rotation.y -= _mouse_delta.x * get_parent().calculated_sensitivity * delta * 100.0
		if get_parent().clamp_y: target_rotation.y = clamp(
			target_rotation.y, get_parent().clamp_y_lower, get_parent().clamp_y_upper)
	smooth_rotation = lerp(smooth_rotation, target_rotation, delta * get_parent().orbit_smoothing)
	_mouse_delta = Vector2.ZERO
