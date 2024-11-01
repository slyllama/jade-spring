@icon("res://lib/decoration/icon_decoration.svg")
class_name Decoration extends Node3D

@export var collision_box: PhysicsBody3D
var last_position: Vector3
var arrows: Array[Arrow] = []

func _spawn_arrows(transform_space: int):
	_clear_arrows()
	
	var _arr_x = Arrow.new()
	if transform_space == Global.TRANSFORM_MODE_WORLD:
		_arr_x.initial_override_rotation = Vector3(0, 0, 0)
	
	_arr_x.set_color(Color.RED)
	add_child(_arr_x)
	arrows.append(_arr_x)
	
	var _arr_y = Arrow.new()
	if transform_space == Global.TRANSFORM_MODE_WORLD:
		_arr_y.initial_override_rotation = Vector3(0, 0, 90)
	else:
		_arr_y.initial_rotation = Vector3(0, 0, 90)
	
	_arr_y.set_color(Color.BLUE)
	add_child(_arr_y)
	arrows.append(_arr_y)
	
	var _arr_z = Arrow.new()
	if transform_space == Global.TRANSFORM_MODE_WORLD:
		_arr_z.initial_override_rotation = Vector3(0, 90, 0)
	else:
		_arr_z.initial_rotation = Vector3(0, 90, 0)
	_arr_z.set_color(Color.GREEN)
	add_child(_arr_z)
	arrows.append(_arr_z)

func _clear_arrows() -> void:
	for _a in arrows: _a.destroy()
	arrows = []

func start_adjustment() -> void:
	Global.active_decoration = self
	Global.adjustment_started.emit()
	Global.tool_mode = Global.TOOL_MODE_ADJUST
	
	_spawn_arrows(Global.transform_mode)
	
	last_position = position
	collision_box.set_collision_layer_value(2, 0)

func apply_adjustment() -> void:
	if Global.active_decoration == self:
		Global.active_decoration = null
		Global.jade_bot_sound.emit()
		
		_clear_arrows() 
		collision_box.set_collision_layer_value(2, 1)

func cancel_adjustment() -> void:
	if Global.active_decoration == self:
		Global.active_decoration = null
		Global.jade_bot_sound.emit()
		
		_clear_arrows() 
		collision_box.set_collision_layer_value(2, 1)
		position = last_position

func _ready() -> void:
	Global.adjustment_canceled.connect(cancel_adjustment)
	Global.adjustment_applied.connect(apply_adjustment)
	
	if collision_box != null:
		collision_box.input_ray_pickable = true
		
		Global.transform_mode_changed.connect(func(transform_mode):
			if !Global.active_decoration == self: return
			_spawn_arrows(transform_mode))
			#if transform_mode == Global.TRANSFORM_MODE_WORLD:
				#gizmo.global_rotation_degrees.y = 0.0
			#elif transform_mode == Global.TRANSFORM_MODE_OBJECT:
				#gizmo.global_rotation = collision_box.global_rotation)
		
		collision_box.mouse_entered.connect(func():
			Global.cursor_tint_changed.emit(Color.GREEN))
		collision_box.mouse_exited.connect(func():
			Global.cursor_tint_changed.emit(Color.RED))
		
		collision_box.input_event.connect(func(_c, _e, _p, _n, _i):
			if (Global.tool_mode != Global.TOOL_MODE_SELECT
				or Global.active_decoration != null): return
			if Input.is_action_just_pressed("left_click"):
				Global.set_cursor(false)
				start_adjustment())
