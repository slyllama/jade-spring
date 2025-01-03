@tool
@icon("res://lib/decoration/icon_decoration.svg")
class_name Decoration extends Node3D
enum {TRANSFORM_TYPE_TRANSLATE, TRANSFORM_TYPE_ROTATE}

@export var id = ""
@export var collision_box: CollisionObject3D
var last_position: Vector3
var last_scale: Vector3
var last_rotation: Vector3
var arrows = []
var transform_type = TRANSFORM_TYPE_TRANSLATE # translation, rotation, or scale
var dye_materials = {}

func get_all_children(node: Node) -> Array:
	var nodes: Array = []
	if !node: return([])
	for n in node.get_children():
		if n.get_child_count() > 0:
			nodes.append(n)
			nodes.append_array(get_all_children(n, ))
		else: nodes.append(n)
	return(nodes)

func assign_dye_channel(material_name: String):
	var _new_m: StandardMaterial3D
	for _n in get_all_children(self):
		if _n is MeshInstance3D:
			var _m = _n.get_active_material(0)
			if _m is StandardMaterial3D:
				if material_name in _m.resource_path:
					_new_m = _m.duplicate()
					dye_materials[material_name] = _new_m
					continue
	
	for _n in get_all_children(self):
		if _n is MeshInstance3D:
			var _m = _n.get_active_material(0)
			if _m is StandardMaterial3D:
				if material_name in _m.resource_path:
					_n.set_surface_override_material(0, _new_m)

func set_dye_channel(material_name: String, albedo_color: Color):
	if material_name in dye_materials:
		var _m = dye_materials[material_name]
		if "albedo_color" in _m:
			_m.albedo_color = albedo_color

func _spawn_rotators() -> void:
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
	
	var _arr_rotate_z = GizmoRotation.new()
	_arr_rotate_z.rotation_vector = Vector3(0, 0, 1)
	_arr_rotate_z.dragger_axis = "Z"
	add_child(_arr_rotate_z)
	arrows.append(_arr_rotate_z)
	_arr_rotate_z.set_color(Color.GREEN)

func _spawn_arrows() -> void:
	_clear_arrows()
	
	var _arr_x = GizmoArrow.new()
	if Global.transform_mode == Global.TRANSFORM_MODE_WORLD:
		_arr_x.initial_override_rotation = Vector3(0, 0, 0)
	_arr_x.set_color(Color.RED)
	add_child(_arr_x)
	arrows.append(_arr_x)
	_arr_x.drag_complete.connect(_spawn_arrows)
	
	var _arr_y = GizmoArrow.new()
	if Global.transform_mode == Global.TRANSFORM_MODE_WORLD:
		_arr_y.initial_override_rotation = Vector3(0, 0, 90)
	else: _arr_y.initial_rotation = Vector3(0, 0, 90)
	_arr_y.set_color(Color.BLUE)
	add_child(_arr_y)
	arrows.append(_arr_y)
	_arr_y.drag_complete.connect(_spawn_arrows)
	
	var _arr_z = GizmoArrow.new()
	if Global.transform_mode == Global.TRANSFORM_MODE_WORLD:
		_arr_z.initial_override_rotation = Vector3(0, 90, 0)
	else: _arr_z.initial_rotation = Vector3(0, 90, 0)
	_arr_z.set_color(Color.GREEN)
	add_child(_arr_z)
	arrows.append(_arr_z)
	_arr_z.drag_complete.connect(_spawn_arrows)
	
	var _scale_gizmo = GizmoScale.new()
	add_child(_scale_gizmo)
	arrows.append(_scale_gizmo)

func _clear_arrows() -> void:
	for _a in arrows: _a.destroy()
	arrows = []

func start_adjustment() -> void:
	Global.deco_pane_closed.emit()
	Global.active_decoration = self
	Global.transform_mode_changed.emit(Global.transform_mode)
	Global.tool_mode = Global.TOOL_MODE_ADJUST
	Global.adjustment_started.emit()
	_spawn_arrows()
	
	transform_type = TRANSFORM_TYPE_TRANSLATE
	last_position = position
	last_scale = scale
	last_rotation = rotation
	collision_box.set_collision_layer_value(2, 0)

func apply_adjustment() -> void:
	collision_box.input_ray_pickable = true
	collision_box.set_collision_layer_value(1, true)
	collision_box.set_collision_layer_value(2, true)
	if Global.active_decoration == self:
		Global.active_decoration = null
		Global.jade_bot_sound.emit()
		
		_clear_arrows() 
		collision_box.set_collision_layer_value(2, 1)
		Global.command_sent.emit("/savedeco")

func cancel_adjustment() -> void:
	collision_box.input_ray_pickable = true
	collision_box.set_collision_layer_value(1, true)
	collision_box.set_collision_layer_value(2, true)
	if Global.active_decoration == self:
		Global.active_decoration = null
		Global.jade_bot_sound.emit()
		
		_clear_arrows() 
		collision_box.set_collision_layer_value(2, 1)
		position = last_position
		scale = last_scale
		rotation = last_rotation

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	Global.adjustment_started.connect(func(): # disable input picking for ALL decorations
		collision_box.set_collision_layer_value(1, false)
		collision_box.set_collision_layer_value(2, false)
		collision_box.input_ray_pickable = false)
	
	Global.adjustment_canceled.connect(cancel_adjustment)
	Global.adjustment_applied.connect(apply_adjustment)
	
	Global.snapping_enabled.connect(func():
		if Global.active_decoration == self:
			var _new_snapped_pos = Vector3(
				snapped(global_position.x, 0.25),
				snapped(global_position.y, 0.25),
				snapped(global_position.z, 0.25))
			global_position = _new_snapped_pos)
	
	# Reset decoration orientation and scale
	Global.adjustment_reset.connect(func():
		if Global.active_decoration == self:
			global_rotation = Vector3.ZERO
			if "y_rotation" in Global.DecoData[id]:
				rotation_degrees.y = Global.DecoData[id].y_rotation
			#last_rotation = global_rotation
			#last_scale = Vector3(1, 1, 1)
			scale = Vector3(1, 1, 1)
			
			# Remake gizmos to suit the new transformation
			if Global.adjustment_mode == Global.ADJUSTMENT_MODE_ROTATE:
				Global.adjustment_mode_rotation.emit()
			else: Global.adjustment_mode_translate.emit())
	
	# Switch controls to translation mode
	Global.adjustment_mode_translate.connect(func():
		if Global.active_decoration == self:
			transform_type = TRANSFORM_TYPE_TRANSLATE
			_clear_arrows()
			_spawn_arrows())
	
	# Switch controls to rotation mode
	Global.adjustment_mode_rotation.connect(func():
		if Global.active_decoration == self:
			# TODO: add rotation controls
			transform_type = TRANSFORM_TYPE_ROTATE
			_clear_arrows()
			_spawn_rotators())
	
	# Snapping rotations from HUD -> Global
	Global.rotate_left_90.connect(func():
		if !Global.active_decoration == self: return
		var _cr = global_rotation_degrees.y # current rotation
		var _nr = round(_cr / 90.0) * 90.0 # new rounded rotation
		global_rotation_degrees = Vector3.ZERO
		global_rotation_degrees.y = _nr - 90.0)
	
	Global.rotate_right_90.connect(func():
		if !Global.active_decoration == self: return
		var _cr = global_rotation_degrees.y # current rotation
		var _nr = round(_cr / 90.0) * 90.0 # new rounded rotation
		global_rotation_degrees = Vector3.ZERO
		global_rotation_degrees.y = _nr + 90.0)
	
	if collision_box != null:
		Global.transform_mode_changed.connect(func(_mode):
			if !Global.active_decoration == self: return
			if transform_type == TRANSFORM_TYPE_TRANSLATE:
				_spawn_arrows())
		
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
