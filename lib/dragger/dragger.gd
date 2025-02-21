extends CanvasLayer
enum Axis { X, Y }

@export var axis: Axis = Axis.X
@export var play_tick = true

@onready var win = get_window().size
@onready var initial_mouse_position = get_window().get_mouse_position()

var active = true
var last_event_relative = Vector2.ZERO
var event_relative = Vector2.ZERO

var ratio := 0.0 # ratio between _dist and half the length of the window along that axis
signal ratio_changed(new_ratio)
signal destroyed

func _set_shader_val(val: float) -> void:
	var _e = ease(val, 0.2)
	var _mat: ShaderMaterial = $ArrowRoot/ArrowLeft.material
	_mat.set_shader_parameter("alpha", _e)
	_mat.set_shader_parameter("paint_exponent", (1 - val) * 10.0)

func destroy() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_window().warp_mouse(initial_mouse_position) # move mouse back to where it was
	
	Global.in_exclusive_ui = false
	active = false
	destroyed.emit()
	
	var dissolve = create_tween()
	dissolve.tween_method(_set_shader_val, 1.0, 0.0, 0.32)
	dissolve.tween_callback(queue_free)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		event_relative = event.relative
	
	if Input.is_action_just_released("left_click"):
		destroy()

func _ready() -> void:
	get_window().focus_exited.connect(destroy)
	
	Global.in_exclusive_ui = true
	var _mat = $ArrowRoot/ArrowLeft.material.duplicate()
	$ArrowRoot/ArrowLeft.material = _mat
	$ArrowRoot/ArrowRight.material = _mat
	$ArrowRoot/Mouse.material = _mat
	
	var dissolve = create_tween()
	dissolve.tween_method(_set_shader_val, 0.0, 1.0, 0.10)
	
	if axis == Axis.Y:
		$ArrowRoot.rotation_degrees = 90.0
	$ArrowRoot.global_position = initial_mouse_position
	$ArrowRoot/Mouse.global_position = initial_mouse_position
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

var last_ratio = ratio
var _accumulated_ratio = 0.0

func _process(delta: float) -> void:
	# Prevent scale continuously changing when the mouse isn't moving
	if event_relative.x == last_event_relative.x:
		event_relative.x = 0
	if event_relative.y == last_event_relative.y:
		event_relative.y = 0
	
	if !active: return
	
	# Process event relative movement and smooth out
	if axis == Axis.X:
		ratio = lerp(ratio, event_relative.x * 0.06, delta * 20)
	elif axis == Axis.Y:
		ratio = lerp(ratio, event_relative.y * 0.06, delta * 20)
		$ArrowRoot/Mouse.rotation_degrees = -90.0
	
	if ratio != last_ratio:
		ratio_changed.emit(ratio)
		last_ratio = ratio
	
	last_event_relative = event_relative
	_accumulated_ratio += ratio
	if _accumulated_ratio > 1.2 or _accumulated_ratio < - 1.2:
		_accumulated_ratio = 0.0
		if play_tick:
			$Tick.play()
