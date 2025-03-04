extends Node3D

signal drag_complete

var dragging = false # is the player dragging the pick box at the moment?
var last_collision = Vector3.ZERO
var collision_delta = Vector3.ZERO
var enabled = true

var last_tick_position

@export var tint = 0.5:
	get: return(tint)
	set(_val):
		tint = _val
		_set_color()

@export var color = Color.WHITE:
	get: return(color)
	set(_val):
		color = _val
		_set_color()

func _set_color() -> void:
	$Drag/Pick/Box.get_active_material(0).set_shader_parameter(
		"color", color * tint)

func set_enabled(state: bool) -> void:
	if !state:
		tint = 0.5
	
	enabled = state
	$Drag/Collision.disabled = !state
	$Drag/Adjacent/Collision.disabled = !state

func destroy() -> void:
	queue_free()

func get_drag_collision():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = Global.camera.project_ray_origin(mouse_pos)
	var to = from + Global.camera.project_ray_normal(mouse_pos) * 200
	var space_state = get_world_3d().direct_space_state
	var mesh_query = PhysicsRayQueryParameters3D.create(from, to)
	
	mesh_query.collide_with_areas = true
	mesh_query.collide_with_bodies = false
	mesh_query.collision_mask = 0b00000000_00000000_00000000_00010000
	
	var intersect = space_state.intersect_ray(mesh_query)
	if intersect != {}:
		if intersect.collider == $Drag:
			return(intersect.position)
		else: return(null)
	else: return(null)

func _input(_event) -> void:
	if !enabled: return
	if Input.is_action_just_released("left_click"):
		if dragging:
			set_enabled(false)
			dragging = false
			Global.mouse_in_ui = false
			Global.in_exclusive_ui = false
			drag_complete.emit()
			var inflate = create_tween()
			inflate.tween_property(
				$Drag/Pick/Box, "scale", Vector3(1.0, 1.0, 1.0), 0.1
			).set_ease(Tween.EASE_IN_OUT)

func _ready() -> void:
	last_tick_position = get_parent().global_position
	
	set_disable_scale(true)
	set_enabled(false)
	$Drag/Pick/VisualAxis.visible = false
	
	for _n in Utilities.get_all_children(self):
		if _n is CollisionShape3D:
			var _s = _n.shape.duplicate()
			_n.shape = _s
	
	var _mat = $Drag/Pick/Box.get_active_material(0).duplicate()
	$Drag/Pick/Box.set_surface_override_material(0, _mat)
	
	Global.drag_started.connect(func():
		$Drag/Pick/Collision.queue_free()
		if !dragging: destroy())
	
	Global.snapping_enabled.connect(func():
		get_parent().global_position = Vector3(
			snapped($Drag/Pick.global_position.x, Global.SNAP_INCREMENT),
			snapped($Drag/Pick.global_position.y, Global.SNAP_INCREMENT),
			snapped($Drag/Pick.global_position.z, Global.SNAP_INCREMENT)
		))

var _wait_frame: int = 0

func _process(delta: float) -> void:
	_wait_frame += 1
	if !enabled: return
	if _wait_frame < 2: return
	
	top_level = false
	$Drag.look_at(Global.player_position)
	$Drag.rotation *= Vector3(0, 1, 0)
	
	if Global.camera_orbiting: return
	
	var _coll = get_drag_collision()
	if _coll:
		$Drag/Cast.global_position = _coll
		$Drag/Cast.position.x += 25.0
		if $Drag/Cast.get_collider() and dragging:
			top_level = true
			
			$Drag/Pick.global_position = lerp(
				$Drag/Pick.global_position,
				$Drag/Cast.get_collision_point() + collision_delta,
				Utilities.critical_lerp(delta, 20.0))
	if !Global.snapping:
		get_parent().global_position = $Drag/Pick.global_position
	else:
		get_parent().global_position = Vector3(
			snapped($Drag/Pick.global_position.x, Global.SNAP_INCREMENT),
			snapped($Drag/Pick.global_position.y, Global.SNAP_INCREMENT),
			snapped($Drag/Pick.global_position.z, Global.SNAP_INCREMENT)
		)
	
	if dragging:
		var _t = last_tick_position.distance_squared_to(get_parent().global_position)
		if _t > 0.05:
			$Tick.play()
			last_tick_position = get_parent().global_position

var _just_pressed = false

func _on_pick_input_event(_c, _e, _p, _n, _i) -> void:
	if Input.is_action_just_pressed("left_click"):
		if _just_pressed: return # no repeats
		_just_pressed = true
		await get_tree().process_frame
		
		if !dragging:
			_wait_frame = 0
			dragging = true
			Global.in_exclusive_ui = true
			$Drag/Pick/VisualAxis.visible = true
			Global.drag_started.emit()
			
			var inflate = create_tween()
			inflate.tween_property(
				$Drag/Pick/Box, "scale", Vector3(1.1, 1.1, 1.1), 0.1
			).set_ease(Tween.EASE_IN_OUT)
			last_collision = $Drag/Cast.get_collision_point()
			collision_delta = $Drag/Pick.global_position - last_collision

func _on_pick_mouse_entered() -> void:
	if dragging: return
	set_enabled(true)
	tint = 1.0
	Global.mouse_in_ui = true

func _on_pick_mouse_exited() -> void:
	if !dragging:
		set_enabled(false)
		tint = 0.5
	Global.mouse_in_ui = false
