extends SubViewportContainer

@onready var model_base = $SubViewport/CharaViewerWorld/Root

var current_model_path := ""
var current_model_animation_player_path := ""
var loaded = false
var loading_status: int
var progress: Array[float]

func _update_resource_loader() -> void:
	if current_model_path == "" or loaded: return
	loading_status = ResourceLoader.load_threaded_get_status(current_model_path, progress)
	match loading_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			if !loaded:
				var loaded_scene = ResourceLoader.load_threaded_get(current_model_path)
				var scene_instance = loaded_scene.instantiate()
				model_base.add_child(scene_instance)
				
				var _anim: AnimationPlayer = scene_instance.get_node_or_null(
					current_model_animation_player_path)
				if _anim:
					_anim.play("dance")
					_anim.animation_finished.connect(func(_a): _anim.play(_a))
			
			await get_tree().process_frame
			var _dissolve_tween = create_tween()
			_dissolve_tween.tween_method(func(_val):
				material.set_shader_parameter("dissolve_value", _val), 0.0, 1.0, 0.45)
			loaded = true
		ResourceLoader.THREAD_LOAD_FAILED:
			print("[CharaViewer] Thread load failed!")
			return

func close() -> void:
	var _dissolve_tween = create_tween()
	_dissolve_tween.tween_method(func(_val):
		material.set_shader_parameter("dissolve_value", _val), 1.0, 0.0, 0.45)
	_dissolve_tween.tween_callback(queue_free)

func load_model(path, animation_player_path) -> void:
	material.set_shader_parameter("dissolve_value", 0.0)
	for _n in model_base.get_children():
		_n.queue_free()
	
	current_model_path = path
	current_model_animation_player_path = animation_player_path
	ResourceLoader.load_threaded_request(path, "", false, ResourceLoader.CACHE_MODE_IGNORE)

func _ready() -> void:
	material.set_shader_parameter("dissolve_value", 0.0)

func _process(_delta: float) -> void:
	_update_resource_loader()

func _on_test_button_down() -> void:
	if current_model_path != "":
		close()
		return
	material.set_shader_parameter("dissolve_value", 0.0)
	loaded = false
	for _i in 3: await get_tree().process_frame
	load_model("res://lib/player/meshes/jade_bot.glb", "AnimationPlayer")
