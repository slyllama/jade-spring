extends CanvasLayer
# Loader
# Facilitates in loading scenes
const TIME = 0.9
const TARGET_SCENE = "res://maps/seitung/seitung.tscn"

var loading_status: int
var progress: Array[float]
var load_bar_bias = 2.0 # only seems to go to 50% by default

#func _set_aberration(value):
	#$Aberration.material.set_shader_parameter("intensity", value)

# Clear parameters set by the previous instance
func _reset_map() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.foliage_count = 0

# Change scene after fading everything out
func _transition():
	var fg: ColorRect = $BG.duplicate()
	fg.self_modulate.a = 0.0
	fg.z_index = 99
	add_child(fg)
	
	var fade = create_tween()
	fade.tween_property(fg, "self_modulate:a", 1.0, TIME)
	var scale_spinner = create_tween()
	scale_spinner.tween_property($Spinner, "scale", Vector2(2.0, 2.0), TIME)
	
	fade.tween_callback(func():
		get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(TARGET_SCENE)))

func _center_cog() -> void:
	# Centralise the spinner (which is a sprite, and not a control node)
	$Spinner.position = get_window().size / Global.retina_scale / 2.0 + Vector2(0, -50.0)

func _ready() -> void:
	var _splash_fade = create_tween()
	_splash_fade.tween_property($Splash, "modulate:a", 0.0, 0.35)
	await _splash_fade.finished
	
	$Splash.queue_free()
	$Spinner.visible = true
	AudioServer.set_bus_volume_db(0, -80)
	
	_reset_map()
	get_window().size_changed.connect(_center_cog)
	_center_cog()
	ResourceLoader.load_threaded_request(TARGET_SCENE)

func _process(delta: float) -> void:
	$Spinner.rotation_degrees += delta * 360.0 # continuous spinning of cog
	loading_status = ResourceLoader.load_threaded_get_status(TARGET_SCENE, progress)
	
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			$Bar.value = lerp(
				$Bar.value, progress[0] * 100.0 * load_bar_bias, 0.1)
		ResourceLoader.THREAD_LOAD_LOADED: _transition()
		ResourceLoader.THREAD_LOAD_FAILED: pass
