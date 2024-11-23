@icon("res://lib/decoration/icon_decoration.svg")
class_name Decoration extends Node3D
enum {TRANSFORM_TYPE_TRANSLATE, TRANSFORM_TYPE_ROTATE}

@export var collision_box: PhysicsBody3D
var last_position: Vector3
var last_scale: Vector3
var last_rotation: Vector3
var arrows = []
var transform_type = TRANSFORM_TYPE_TRANSLATE # translation, rotation, or scale

func _spawn_arrows(transform_space: int):
	_clear_arrows()
	
	var _arr_x = GizmoArrow.new()
	if transform_space == Global.TRANSFORM_MODE_WORLD:
		_arr_x.initial_override_rotation = Vector3(0, 0, 0)
	
	_arr_x.set_color(Color.RED)
	add_child(_arr_x)
	arrows.append(_arr_x)
	
	var _arr_y = GizmoArrow.new()
	if transform_space == Global.TRANSFORM_MODE_WORLD:
		_arr_y.initial_override_rotation = Vector3(0, 0, 90)
	else:
		_arr_y.initial_rotation = Vector3(0, 0, 90)
	
	_arr_y.set_color(Color.BLUE)
	add_child(_arr_y)
	arrows.append(_arr_y)
	
	var _arr_z = GizmoArrow.new()
	if transform_space == Global.TRANSFORM_MODE_WORLD:
		_arr_z.initial_override_rotation = Vector3(0, 90, 0)
	else:
		_arr_z.initial_rotation = Vector3(0, 90, 0)
	_arr_z.set_color(Color.GREEN)
	add_child(_arr_z)
	arrows.append(_arr_z)
	
	var _scale_gizmo = GizmoScale.new()
	add_child(_scale_gizmo)
	arrows.append(_scale_gizmo)

func _clear_arrows() -> void:
	for _a in arrows: _a.destroy()
	arrows = []

func start_adjustment() -> void:
	Global.deco_pane_closed.emit() # decoration pane will not close until the adjustment is initiated
	Global.active_decoration = self
	
	Global.transform_mode = Global.TRANSFORM_MODE_OBJECT
	Global.transform_mode_changed.emit(Global.transform_mode)
	Global.tool_mode = Global.TOOL_MODE_ADJUST
	Global.adjustment_started.emit()
	_spawn_arrows(Global.transform_mode)
	
	transform_type = TRANSFORM_TYPE_TRANSLATE
	last_position = position
	last_scale = scale
	last_rotation = rotation
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
		scale = last_scale
		rotation = last_rotation

func _ready() -> void:
	Global.adjustment_canceled.connect(cancel_adjustment)
	Global.adjustment_applied.connect(apply_adjustment)
	
	# Switch controls to translation mode
	Global.adjustment_mode_translate.connect(func():
		if Global.active_decoration == self:
			transform_type = TRANSFORM_TYPE_TRANSLATE
			_spawn_arrows(Global.transform_mode))
	
	# Switch controls to rotation mode
	Global.adjustment_mode_rotation.connect(func():
		if Global.active_decoration == self:
			# TODO: add rotation controls
			transform_type = TRANSFORM_TYPE_ROTATE
			_clear_arrows()
			
			var _arr_rotate_x = GizmoRotation.new()
			_arr_rotate_x.rotation_vector = Vector3(1, 0, 0)
			_arr_rotate_x.dragger_axis = "Y"
			add_child(_arr_rotate_x)
			arrows.append(_arr_rotate_x)
			_arr_rotate_x.set_color(Color.RED)
			
			var _arr_rotate_y = GizmoRotation.new()
			_arr_rotate_y.rotation_vector = Vector3(0, 1, 0)
			_arr_rotate_y.dragger_axis = "X"
			add_child(_arr_rotate_y)
			arrows.append(_arr_rotate_y)
			_arr_rotate_y.set_color(Color.BLUE)
			)
	
	if collision_box != null:
		collision_box.input_ray_pickable = true
		
		Global.transform_mode_changed.connect(func(transform_mode):
			if !Global.active_decoration == self: return
			if transform_type == TRANSFORM_TYPE_TRANSLATE:
				_spawn_arrows(transform_mode))
		
		collision_box.mouse_entered.connect(func():
			Global.cursor_tint_changed.emit(Color.GREEN))
		collision_box.mouse_exited.connect(func():
			Global.cursor_tint_changed.emit(Color.RED))
		
		collision_box.input_event.connect(func(_c, _e, _p, _n, _i):
			if Global.active_decoration != null: return
			
			if Input.is_action_just_pressed("left_click"):
				if Global.tool_mode == Global.TOOL_MODE_SELECT:
					Global.set_cursor(false)
					start_adjustment()
				elif Global.tool_mode == Global.TOOL_MODE_DELETE:
					Global.set_cursor(false)
					
					Global.tool_mode = Global.TOOL_MODE_NONE
					Global.deco_deleted.emit()
					
					queue_free() # TODO: better delete communication?
			)
