extends Node3D

func get_drag_collision():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = Global.camera.project_ray_origin(mouse_pos)
	var to = from + Global.camera.project_ray_normal(mouse_pos) * 200
	var space_state = get_world_3d().direct_space_state
	var mesh_query = PhysicsRayQueryParameters3D.create(from, to)
	
	mesh_query.collide_with_areas = true
	mesh_query.collide_with_bodies = false
	mesh_query.collision_mask = 0b00000000_00000000_00000000_00000010
	
	var intersect = space_state.intersect_ray(mesh_query)
	if intersect != {}:
		if intersect.collider == $Drag:
			return(intersect.position)
		else: return(null)
	else: return(null)

func _process(delta: float) -> void:
	if Global.camera_orbiting: return
	var _coll = get_drag_collision()
	if _coll:
		$Drag/Cast.global_position = _coll
		$Drag/Cast.position.z -= 0.05
		$Drag/Cast.position.x += 0.5
		if $Drag/Cast.get_collider():
			$Drag/Pick.global_position = lerp(
				$Drag/Pick.global_position, $Drag/Cast.get_collision_point(), delta * 20.0)
	
	$Drag.look_at(Global.player_position)
	$Drag.rotation *= Vector3(0, 1, 0)
