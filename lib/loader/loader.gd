extends CanvasLayer
# Loader
# Facilitates in loading scenes
const TIME = 0.9
const TARGET_SCENE = "res://maps/seitung/seitung.tscn"
var target_scene = TARGET_SCENE

var loading_status: int
var progress: Array[float]
var load_bar_bias = 2.0 # only seems to go to 50% by default

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

	fade.tween_callback(func():
		get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(target_scene)))

func _ready() -> void:
	$Decorations.modulate.a = 0.0
	var _deco_fade_in = create_tween()
	_deco_fade_in.tween_property($Decorations, "modulate:a", 1.0, 0.2)
	
	AudioServer.set_bus_volume_db(0, -80)
	SettingsHandler.setting_changed.connect(func(parameter):
		var _value = SettingsHandler.settings[parameter]
		match parameter:
			"window_mode":
				if _value == "full_screen": get_window().mode = Window.MODE_FULLSCREEN
				elif _value == "maximized": get_window().mode = Window.MODE_MAXIMIZED
				else: get_window().mode = Window.MODE_WINDOWED
	)
	SettingsHandler.refresh(["volume"])
	
	_reset_map()
	ResourceLoader.load_threaded_request(target_scene)

func _process(_delta: float) -> void:
	loading_status = ResourceLoader.load_threaded_get_status(target_scene, progress)
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			$Bar.value = lerp(
				$Bar.value, progress[0] * 100.0 * load_bar_bias, 0.1)
		ResourceLoader.THREAD_LOAD_LOADED: _transition()
		ResourceLoader.THREAD_LOAD_FAILED: pass
