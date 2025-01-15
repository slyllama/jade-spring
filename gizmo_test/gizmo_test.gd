extends Node3D

var dragging = false # is the player dragging the pick box at the moment?
var last_collision = Vector3.ZERO
var collision_delta = Vector3.ZERO

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
	if Input.is_action_just_released("left_click"):
		if dragging:
			dragging = false
			var inflate = create_tween()
			inflate.tween_property(
				$Drag/Pick/Box, "scale", Vector3(1.0, 1.0, 1.0), 0.1
			).set_ease(Tween.EASE_IN_OUT)

func _ready() -> void:
	top_level = true

func _process(delta: float) -> void:
	$Drag.look_at(Global.player_position)
	$Drag.rotation *= Vector3(0, 1, 0)
	
	if Global.camera_orbiting: return
	
	var _coll = get_drag_collision()
	if _coll:
		$Drag/Cast.global_position = _coll
		$Drag/Cast.position.x += 25.0
		if $Drag/Cast.get_collider() and dragging:
			$Drag/Pick.global_position = lerp(
				$Drag/Pick.global_position,
				$Drag/Cast.get_collision_point() + collision_delta,
				delta * 20.0)

func _on_pick_input_event(_c, _e, _p, _n, _i) -> void:
	if Input.is_action_pressed("left_click"):
		if !dragging:
			dragging = true
			
			var inflate = create_tween()
			inflate.tween_property(
				$Drag/Pick/Box, "scale", Vector3(1.1, 1.1, 1.1), 0.1
			).set_ease(Tween.EASE_IN_OUT)
			last_collision = $Drag/Cast.get_collision_point()
			collision_delta = $Drag/Pick.global_position - last_collision

func _on_pick_mouse_entered() -> void: Global.mouse_in_ui = true
func _on_pick_mouse_exited() -> void: Global.mouse_in_ui = false
