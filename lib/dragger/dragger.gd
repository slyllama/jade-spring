extends CanvasLayer
enum Axis { X, Y }

@export var axis: Axis = Axis.X

@onready var win = get_window().size
var last_mouse_click = Vector2.ZERO

var active = true
var ratio:= 0.0 # ratio between _dist and half the length of the window along that axis
signal ratio_changed(new_ratio)

func _set_shader_val(val: float) -> void:
	var _e = ease(val, 0.2)
	var _mat: ShaderMaterial = $ArrowRoot/ArrowLeft.material
	_mat.set_shader_parameter("alpha", _e)
	_mat.set_shader_parameter("paint_exponent", (1 - val) * 10.0)

func destroy() -> void:
	Global.in_exclusive_ui = false
	$Debug.visible = false
	active = false
	
	var dissolve = create_tween()
	dissolve.tween_method(_set_shader_val, 1.0, 0.0, 0.32)
	dissolve.tween_callback(queue_free)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var _mouse_pos = get_window().get_mouse_position()
		var _dist := 0.0 # distance between mouse position and last mouse down along an axis
		
		if axis == Axis.X:
			_dist = _mouse_pos.x - last_mouse_click.x
			ratio = _dist / win.x
		elif axis == Axis.Y:
			_dist = _mouse_pos.y - last_mouse_click.y
			ratio = _dist / win.y
	
	if Input.is_action_just_released("left_click"):
		destroy()

func _ready() -> void:
	Global.in_exclusive_ui = true
	var _mat = $ArrowRoot/ArrowLeft.material.duplicate()
	$ArrowRoot/ArrowLeft.material = _mat
	$ArrowRoot/ArrowRight.material = _mat
	
	var dissolve = create_tween()
	dissolve.tween_method(_set_shader_val, 0.0, 1.0, 0.10)
	
	if axis == Axis.Y:
		$ArrowRoot.rotation_degrees = 90.0
	last_mouse_click = get_window().get_mouse_position()
	$ArrowRoot.position = last_mouse_click

var last_ratio = ratio

func _process(_delta: float) -> void:
	if !active: return
	
	$Debug.position = get_window().get_mouse_position() + Vector2(80, 0)
	$Debug.text = str(snapped(ratio, 0.01))
	
	if ratio != last_ratio:
		ratio_changed.emit(ratio)
		last_ratio = ratio
