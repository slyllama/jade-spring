@tool
extends Node
# OrbitHandler
# Handles getting mouse drag events for orbiting

var orbiting = false
var target_rotation = Vector3.ZERO
var smooth_rotation = Vector3.ZERO
var smooth_modifier = 1.0 # orbit smoothing will be multiplied by this value - used for commands

var action_cam_is_default = true
var action_cam_active = false
var action_cam_paused = false

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
		_disable_action_cam()
		
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		await get_tree().process_frame
		Global.camera_orbiting = false
		orbiting = false)
	
	Global.action_cam_enable.connect(_enable_action_cam)
	Global.action_cam_disable.connect(_disable_action_cam)
	
	Global.command_sent.connect(func(_cmd):
		if "/orbitsmooth=" in _cmd:
			var _o = float(_cmd.replace("/orbitsmooth=", ""))
			smooth_modifier = clamp(_o, 0.01, 1.0))

func _enable_action_cam(override = false) -> void:
	# Prevent action cam reactivating in certain tool modes where the cursor is important
	if (Global.tool_mode == Global.TOOL_MODE_SELECT
		or Global.tool_mode == Global.TOOL_MODE_DELETE
		or Global.tool_mode == Global.TOOL_MODE_ADJUST
		or Global.tool_mode == Global.TOOL_MODE_PLACE
		or Global.deco_pane_open):
		return
	
	await get_tree().process_frame
	if Global.in_exclusive_ui: return
	if SettingsHandler.settings.action_camera == "on_by_default" or override:
		Global.hud.get_node("Cursor").visible = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_clicked_in_ui = false
		action_cam_active = true

func _disable_action_cam() -> void:
	for _i in 2: await get_tree().process_frame
	Global.hud.get_node("Cursor").visible = false
	action_cam_active = false
	_clicked_in_ui = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.camera_orbiting = false
	orbiting = false

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	
	# Use key to toggle action camera
	if Input.is_action_just_pressed("action_camera"):
		if action_cam_active: _disable_action_cam()
		else: _enable_action_cam(true)
	
	if Input.is_action_just_pressed(get_parent().left_click) or Input.is_action_just_pressed("right_click"):
		if (
			!Global.in_exclusive_ui and
			!Global.mouse_in_ui and
			!Global.dialogue_open and
			!Global.story_panel_open and
			!Global.settings_open):
			_enable_action_cam()
		if get_parent().orbit_disabled: return
		if get_parent().mouse_in_ui:
			_clicked_in_ui = true
		else:
			get_viewport().gui_release_focus()
		_last_click_position = get_window().get_mouse_position()
	if Input.is_action_just_released(get_parent().left_click) or Input.is_action_just_released("right_click"):
		if action_cam_active and !action_cam_paused: return
		_clicked_in_ui = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Global.camera_orbiting = false
		orbiting = false
	
	if event is InputEventMouseMotion:
		_mouse_delta = event.relative

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if get_parent().orbit_disabled: return
	if get_parent().in_exclusive_ui and !get_parent().ignore_exclusive_ui:
		return
	
	# Determine if either mouse button is currently down
	var _mouse_button_down = false
	if action_cam_active and !action_cam_paused:
		_mouse_button_down = true
	else:
		if (Input.is_action_pressed("left_click")
			or Input.is_action_pressed("right_click")):
			_mouse_button_down = true
	
	# Only enter orbit mode after dragging the screen a certain amount i.e., not instantly
	if (!orbiting and !_clicked_in_ui and _mouse_button_down
		and !get_parent().popup_open and !Global.in_exclusive_ui):
		var _mouse_offset = get_window().get_mouse_position() - _last_click_position
		if abs(_mouse_offset.x) > 5 or abs(_mouse_offset.y) > 5:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Global.camera_orbiting = true
			orbiting = true
	
	# Process relative mouse movement (_mouse_delta)
	# This is handled here instead of _input() because handling without delta
	# causes strange behaviour at low frame rates
	if orbiting:
		target_rotation.x -= _mouse_delta.y * Global.orbit_sensitivity_multiplier * delta * 60.0
		if get_parent().clamp_x: target_rotation.x = clamp(
			target_rotation.x, get_parent().clamp_x_lower, get_parent().clamp_x_upper)
		target_rotation.y -= _mouse_delta.x * Global.orbit_sensitivity_multiplier * delta * 60.0
		if get_parent().clamp_y: target_rotation.y = clamp(
			target_rotation.y, get_parent().clamp_y_lower, get_parent().clamp_y_upper)
	smooth_rotation = lerp(smooth_rotation, target_rotation, delta * get_parent().orbit_smoothing * smooth_modifier)
	_mouse_delta = Vector2.ZERO
