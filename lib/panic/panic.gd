class_name Panic extends Node

@export var dump_file_name: String
@export var camera: Camera3D

var cube: MeshInstance3D

func generate_debug_mesh() -> void:
	if !camera: return
	cube = MeshInstance3D.new()
	var _cube_mesh := BoxMesh.new()
	_cube_mesh.size = Vector3(0.45, 0.45, 0.45)
	cube.mesh = _cube_mesh
	
	camera.add_child(cube)
	cube.position.z -= 1.0

func dump_render_state() -> void:
	if !dump_file_name or !".log" in dump_file_name: return
	
	var dump_string := ""
	var current_time := Time.get_datetime_string_from_system()
	current_time = current_time.replace("T", " ").replace(":", "-")
	dump_string += "--- Render dump (" + current_time + ") ---"
	dump_string += "\nCamera:"
	if camera:
		dump_string += "\n * global_transform = " + str(camera.global_transform)
		dump_string += "\n * current = " + str(camera.current)
		dump_string += "\n * cull_mask = " + str(camera.cull_mask)
		dump_string += "\n * near = " + str(snapped(camera.near, 0.01))
		dump_string += "\n * far = " + str(snapped(camera.far, 0.01))
		dump_string += "\n * get_world_3d() = " + str(camera.get_world_3d())
		dump_string += "\n * get_viewport() = " + str(camera.get_viewport())
	else: dump_string += "\n * Warning: no camera assigned."
	
	var dump_file := FileAccess.open(
		"user://" + dump_file_name, FileAccess.WRITE)
	dump_file.store_string(dump_string)
	dump_file.close()

func _physics_process(delta: float) -> void:
	if cube: cube.rotation.y += delta

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_home"):
		generate_debug_mesh()
		dump_render_state()
