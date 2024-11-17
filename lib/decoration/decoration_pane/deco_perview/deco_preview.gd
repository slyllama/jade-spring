extends Node3D

var orbiting = false
var target_rotation = Vector3.ZERO
var smooth_rotation = Vector3.ZERO
@export var orbit_sensitivity := 0.15
@export var orbit_smoothing := 12.0
@onready var calculated_sensitivity = orbit_sensitivity

var _mouse_delta = Vector2.ZERO # event.relative
var _clicked_in_ui = false
var _last_click_position = Vector2.ZERO

var current_model_path := ""
var current_preview_scale := 1.0
var current_y_rotation := 0.0 # degrees
var loaded = false
var loading_status: int

var progress: Array[float]

func _update_resource_loader() -> void:
	if current_model_path == "": return
	loading_status = ResourceLoader.load_threaded_get_status(current_model_path, progress)
	match loading_status:
		#ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			#pass
		ResourceLoader.THREAD_LOAD_LOADED:
			if !loaded:
				var loaded_scene = ResourceLoader.load_threaded_get(current_model_path)
				var scene_instance = loaded_scene.instantiate()
				$ModelBase.add_child(scene_instance)
				scene_instance.scale = Vector3(
					current_preview_scale, current_preview_scale, current_preview_scale)
			loaded = true
		ResourceLoader.THREAD_LOAD_FAILED: pass

func clear_model() -> void:
	target_rotation = Vector3.ZERO
	$Orbit.rotation = Vector3.ZERO
	loaded = false
	for _n in $ModelBase.get_children():
		_n.queue_free()

func load_model(path: String, preview_scale = 1.0, y_rotation = 0.0) -> void:
	clear_model()
	
	current_y_rotation = y_rotation
	current_model_path = path
	current_preview_scale = preview_scale
	
	$ModelBase.rotation_degrees.y = current_y_rotation
	ResourceLoader.load_threaded_request(path)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if Input.is_action_just_pressed("left_click"):
		if Global.mouse_in_deco_pane:
			_clicked_in_ui = true
		else:
			get_viewport().gui_release_focus()
			_last_click_position = get_window().get_mouse_position()
	if Input.is_action_just_released("left_click"):
		_clicked_in_ui = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Global.camera_orbiting = false
		orbiting = false
	
	if event is InputEventMouseMotion:
		_mouse_delta = event.relative

func _process(delta: float) -> void:
	_update_resource_loader()
	
	# Handle orbiting
	# Only enter orbit mode after dragging the screen a certain amount i.e., not instantly
	if (!orbiting and _clicked_in_ui and Input.is_action_pressed("left_click")):
		var _mouse_offset = get_window().get_mouse_position() - _last_click_position
		if abs(_mouse_offset.x) > 5 or abs(_mouse_offset.y) > 5:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Global.camera_orbiting = true
			orbiting = true
	
	if orbiting:
		target_rotation.y -= _mouse_delta.x * calculated_sensitivity * delta * 4
	smooth_rotation = lerp(smooth_rotation, target_rotation, delta * orbit_smoothing)
	$Orbit.rotation = smooth_rotation
	_mouse_delta = Vector2.ZERO
