extends CanvasLayer
# Loader
# Facilitates in loading scenes
const TIME = 0.9
const TARGET_SCENE = "res://maps/seitung/seitung.tscn"
var target_scene = TARGET_SCENE

var loading_status: int
var progress: Array[float]
var load_bar_bias = 2.0 # only seems to go to 50% by default
var has_loaded = false
var transitioning = false

# Clear parameters set by the previous instance
func _reset_map() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.foliage_count = 0

# Change scene after fading everything out
func _transition():
	if transitioning: return
	transitioning = true
	
	Save.load_from_file()
	await get_tree().process_frame
	
	var fg: ColorRect = $BG.duplicate()
	fg.self_modulate.a = 0.0
	fg.z_index = 99
	add_child(fg)
	
	var fade = create_tween()
	fade.tween_property(fg, "self_modulate:a", 1.0, TIME / 2.0)

	fade.tween_callback(func():
		get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(target_scene)))

func _ready() -> void:
	$Decorations.modulate.a = 0.0
	$Spinner.visible = true
	
	if Global.load_debug_next:
		target_scene = "res://maps/debug/debug.tscn"
	Global.load_debug_next = false
	
	var _deco_fade_in = create_tween()
	_deco_fade_in.tween_property($Decorations, "modulate:a", 1.0, 0.2)
	
	AudioServer.set_bus_volume_db(0, -80)
	SettingsHandler.setting_changed.connect(func(parameter):
		var _value = SettingsHandler.settings[parameter]
		match parameter:
			"window_mode": Utilities.set_window_mode(_value)
	)
	SettingsHandler.refresh(["volume"])
	
	_reset_map()
	ResourceLoader.load_threaded_request(target_scene)

func _process(delta: float) -> void:
	$Spinner.position.x = get_window().size.x / 2.0 / Global.retina_scale
	$Spinner.position.y = float(get_window().size.y) / Global.retina_scale - 102.0
	$Spinner.rotation_degrees += delta * 240.0
	loading_status = ResourceLoader.load_threaded_get_status(target_scene, progress)
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			$Bar.value = lerp(
				$Bar.value, progress[0] * 100.0 * load_bar_bias, 0.1)
		ResourceLoader.THREAD_LOAD_LOADED:
			if Save.first_run:
				if has_loaded: return
				has_loaded = true # only once
				$Bar/ContinueButton.modulate.a = 0.0
				$Spinner.visible = false
				$Bar/ContinueButton.visible = true
				$Bar/ContinueButton.grab_focus()
				
				var fade_button = create_tween()
				fade_button.tween_property($Bar/ContinueButton, "modulate:a", 1.0, 0.35)
				var fade_bar = create_tween()
				fade_bar.tween_property($Bar, "self_modulate:a", 0.0, 0.35)
				
				var _flash = load("res://lib/flash/flash.tscn").instantiate()
				_flash.position = ($Bar/ContinueButton.global_position
					+ Vector2($Bar/ContinueButton.size.x / 2.0, 0))
				add_child(_flash)
			else:
				_transition()
			
		ResourceLoader.THREAD_LOAD_FAILED: pass

func _on_continue_button_down() -> void:
	_transition()
