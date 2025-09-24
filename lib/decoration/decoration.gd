@tool
@icon("res://lib/decoration/icon_decoration.svg")
class_name Decoration extends Node3D
enum {TRANSFORM_TYPE_TRANSLATE, TRANSFORM_TYPE_ROTATE}

const GizmoArrow = preload("res://lib/gizmo/gizmo_arrow/gizmo_arrow.tscn")
const OutlineMaterial = preload("res://generic/materials/mat_outline.tres")
const SelectionIcon = preload("res://lib/decoration/selection_icon.gd")
const Grid = preload("res://lib/grid/grid.tscn")

@export var id = ""
@export var collision_box: CollisionObject3D
var outline_mat: ShaderMaterial
var last_position: Vector3
var last_scale: Vector3
var last_rotation: Vector3
var arrows = []
var transform_type = TRANSFORM_TYPE_TRANSLATE # translation, rotation, or scale
var dye_materials = {}
var cull_distance = 32.0
var distance_to_player = 0.0
var mouse_in_box = false
var outlined = false

@onready var selection_icon = SelectionIcon.new()
var selected = false

func set_selected(state = true) -> void:
	selected = state
	if selected: # only emit click on select (not deselect)
		Global.click_sound.emit()
	if state:
		for _i in 4: await get_tree().process_frame
		selection_icon.set_active()
		outline_mat.set_shader_parameter("outline_color", Color.WHITE)
		outline_mat.set_shader_parameter("outline_width", 0.5)
	else:
		selection_icon.set_active(false)
		outline_mat.set_shader_parameter("outline_color", Color.TRANSPARENT)
		outline_mat.set_shader_parameter("outline_width", 0)

func set_outline(state = true) -> void:
	if selected: return
	if state:
		for _i in 2: await get_tree().process_frame # give the cursor a chance to be re-added
		if Global.cursor_active and Global.highlighted_decoration == self:
			outline_mat.set_shader_parameter("outline_color", Color.GREEN_YELLOW)
			outline_mat.set_shader_parameter("outline_width", 0.35)
	else:
		outline_mat.set_shader_parameter("outline_color", Color.TRANSPARENT)
		outline_mat.set_shader_parameter("outline_width", 0)

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

var last_rotator = null

func _spawn_rotators() -> void:
	_clear_arrows()
	
	var _arr_rotate_x = GizmoRotation.new()
	_arr_rotate_x.rotation_vector = Vector3(1, 0, 0)
	_arr_rotate_x.dragger_axis = "X"
	_arr_rotate_x.mouse_entered.connect(func():
		last_rotator = _arr_rotate_x)
	add_child(_arr_rotate_x)
	arrows.append(_arr_rotate_x)
	_arr_rotate_x.set_color(Color.RED)
	
	var _arr_rotate_y = GizmoRotation.new()
	_arr_rotate_y.rotation_vector = Vector3(0, 1, 0)
	_arr_rotate_y.dragger_axis = "X"
	_arr_rotate_y.mouse_entered.connect(func():
		last_rotator = _arr_rotate_y)
	add_child(_arr_rotate_y)
	arrows.append(_arr_rotate_y)
	_arr_rotate_y.set_color(Color.BLUE)
	
	var _arr_rotate_z = GizmoRotation.new()
	_arr_rotate_z.rotation_vector = Vector3(0, 0, 1)
	_arr_rotate_z.dragger_axis = "X"
	_arr_rotate_z.mouse_entered.connect(func():
		last_rotator = _arr_rotate_z)
	add_child(_arr_rotate_z)
	arrows.append(_arr_rotate_z)
	_arr_rotate_z.set_color(Color.GREEN)

func _spawn_arrows() -> void:
	_clear_arrows()
	
	var _arr_x = GizmoArrow.instantiate()
	_arr_x.color = Color.RED
	add_child(_arr_x)
	if Global.transform_mode == Global.TRANSFORM_MODE_WORLD:
		_arr_x.global_rotation_degrees = Vector3(90.0, 0, 0)
	else:
		_arr_x.rotation_degrees = Vector3(90.0, 0, 0)
	arrows.append(_arr_x)
	_arr_x.drag_complete.connect(_spawn_arrows)
	
	var _arr_y = GizmoArrow.instantiate()
	_arr_y.color = Color.GREEN
	add_child(_arr_y)
	if Global.transform_mode == Global.TRANSFORM_MODE_WORLD:
		_arr_y.global_rotation_degrees = Vector3(90.0, 90.0, 0)
	else:
		_arr_y.rotation_degrees = Vector3(90.0, 90.0, 0)
	arrows.append(_arr_y)
	_arr_y.drag_complete.connect(_spawn_arrows)
	
	var _arr_z = GizmoArrow.instantiate()
	_arr_z.color = Color.BLUE
	add_child(_arr_z)
	if Global.transform_mode == Global.TRANSFORM_MODE_WORLD:
		_arr_z.global_rotation_degrees = Vector3(0, 90.0, 0)
	else:
		_arr_z.rotation_degrees = Vector3(0, 90.0, 0)
	arrows.append(_arr_z)
	_arr_z.drag_complete.connect(_spawn_arrows)
	
	var _scale_gizmo = GizmoScale.new()
	add_child(_scale_gizmo)
	arrows.append(_scale_gizmo)

func _clear_arrows() -> void:
	for _a in arrows:
		if is_instance_valid(_a): # can't clear an arrow that's already been cleared
			_a.destroy()
	arrows = []

func start_adjustment() -> void:
	#select_label.fade_in()
	
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
	if collision_box != null:
		collision_box.set_collision_layer_value(2, 0)

func apply_adjustment() -> void:
	set_selected(false)
	if collision_box != null:
		collision_box.input_ray_pickable = true
		collision_box.set_collision_layer_value(1, true)
		collision_box.set_collision_layer_value(2, true)
	if Global.active_decoration == self:
		#select_label.fade_out()
		Global.active_decoration = null
		Global.jade_bot_sound.emit()
		
		_clear_arrows()
		_replace_grid(true)
		if collision_box:
			collision_box.set_collision_layer_value(2, 1)
		else:
			print("[Decoration] Collision box unassigned for " + str(id) + ".")
		Global.command_sent.emit("/savedeco")
	
	await get_tree().process_frame
	set_outline(false)
	Global.mouse_in_ui = false

func cancel_adjustment() -> void:
	set_selected(false)
	if collision_box != null:
		collision_box.input_ray_pickable = true
		collision_box.set_collision_layer_value(1, true)
		collision_box.set_collision_layer_value(2, true)
	if Global.active_decoration == self:
		#select_label.fade_out()
		print("clear")
		_replace_grid(true)
		Global.active_decoration = null
		Global.jade_bot_sound.emit()
		
		_clear_arrows()
		
		collision_box.set_collision_layer_value(2, 1)
		position = last_position
		scale = last_scale
		rotation = last_rotation
	
	await get_tree().process_frame
	set_outline(false)
	Global.mouse_in_ui = false

var _g = null
func _replace_grid(clear = false) -> void:
	if _g:
		_g.disappear()
	if !Global.snapping or clear: return
	if _g: await(_g.tree_exiting)
	_g = Grid.instantiate()
	add_child.call_deferred(_g)
	await _g.ready
	_g.global_position = global_position

func _ready() -> void:
	if Engine.is_editor_hint(): return
	add_child(selection_icon)
	
	if "a_cull" in Global.DecoData[id]:
		if Global.DecoData[id].a_cull == true and get_parent() is DecoHandler:
			var _dm = DistanceMonitor.new()
			add_child(_dm)
	
	outline_mat = OutlineMaterial.duplicate(true)
	for _n in Utilities.get_all_children(self):
		if _n is MeshInstance3D:
			var _valid = true
			if !_n.get_active_material(0):
				print("[Decoration] '" + id + "' missing active material, skipping.")
				continue
			var _mat = _n.get_active_material(0).duplicate()
			_n.set_surface_override_material(0, _mat)
			if _mat is ShaderMaterial:
				if "shader_parameter/alpha_scissor_threshold" in _mat:
					_valid = false
				if "shader_parameter/alpha" in _mat:
					_valid = false
			if _mat is StandardMaterial3D:
				if _mat.transparency != StandardMaterial3D.TRANSPARENCY_DISABLED:
					_valid = false
			if _valid:
				_mat.next_pass = outline_mat
	set_outline(false)

	Global.adjustment_started.connect(func(): # disable input picking for ALL decorations
		set_outline(false)
		if collision_box != null:
			collision_box.set_collision_layer_value(1, false)
			collision_box.set_collision_layer_value(2, false)
			collision_box.input_ray_pickable = false)
	
	Global.adjustment_canceled.connect(cancel_adjustment)
	Global.adjustment_applied.connect(apply_adjustment)
	
	Global.deco_deletion_started.connect(func():
		if mouse_in_box:
			set_outline())
	Global.deco_deletion_canceled.connect(func():
		_replace_grid(true)
		set_outline(false))
	
	Global.selection_started.connect(func():
		if mouse_in_box:
			set_outline())
	Global.selection_canceled.connect(func():
		_replace_grid(true)
		set_outline(false))
	
	Global.snapping_enabled.connect(func():
		if (Global.active_decoration == self
			and Global.adjustment_mode == Global.ADJUSTMENT_MODE_TRANSLATE):
			var _new_snapped_pos = Vector3(
				snapped(global_position.x, 0.25),
				snapped(global_position.y, 0.25),
				snapped(global_position.z, 0.25))
			global_position = _new_snapped_pos
			
			_replace_grid())
	
	Global.snapping_disabled.connect(func():
		_replace_grid(true))
	
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
			_replace_grid()
			transform_type = TRANSFORM_TYPE_TRANSLATE
			_clear_arrows()
			_spawn_arrows())
	
	# Switch controls to rotation mode
	Global.adjustment_mode_rotation.connect(func():
		if Global.active_decoration == self:
			# TODO: add rotation controls
			transform_type = TRANSFORM_TYPE_ROTATE
			_replace_grid(true)
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
			Global.highlighted_decoration = self
			mouse_in_box = true
			if !Global.tool_mode == Global.TOOL_MODE_PLACE:
				set_outline()
			Global.cursor_tint_changed.emit(Color.GREEN))
		collision_box.mouse_exited.connect(func():
			mouse_in_box = false
			set_outline(false)
			Global.cursor_tint_changed.emit(Color.RED))
		
		collision_box.input_event.connect(func(_c, _e, _p, _n, _i):
			if Global.active_decoration != null: return
			
			if Input.is_action_just_pressed("left_click"):
				if Global.on_skill_cooldown: return
				Global.do_skill_cooldown()
				if Global.tool_mode == Global.TOOL_MODE_SELECT:
					Global.set_cursor(false)
					start_adjustment()
				elif Global.tool_mode == Global.TOOL_MODE_SELECT_MULTIPLE:
					var _is_in_array = false
					var _entry_in_array = null
					for _f in Global.deco_selection_array:
						if _f.node == self:
							_entry_in_array = _f
							_is_in_array = true
							break
					if !_is_in_array:
						set_selected()
						Global.deco_selection_array.push_front({
							"node": self,
							"last_position": position
						})
					else:
						Global.deco_selection_array.erase(_entry_in_array)
						set_selected(false)
				elif Global.tool_mode == Global.TOOL_MODE_DELETE:
					Global.deco_deleted.emit()
					Global.decorations.erase(self)
					queue_free()
				elif Global.tool_mode == Global.TOOL_MODE_EYEDROPPER:
					Global.deco_sampled.emit({
						"id": id,
						"rotation": rotation,
						"eyedrop_scale": scale
					})
			)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if !Global.active_decoration == self: return
	if Global.tool_mode == Global.TOOL_MODE_ADJUST:
		if Global.deco_selection_array.size() > 1:
			var _pos_diff = last_position - position
			for i in range(1, Global.deco_selection_array.size()):
				var _sd = Global.deco_selection_array[i]
				_sd.node.position = _sd.last_position - _pos_diff
