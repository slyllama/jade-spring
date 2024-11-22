extends CanvasLayer

const LOADER_SCENE = "res://lib/loader/loader.tscn"

@onready var nodule_pos = Vector2.ZERO

# Connections and tweens to make the focus nodule look right
func set_up_nodule() -> void:
	$Nodule.modulate.a = 0.0
	
	$Container/PlayButton.focus_entered.connect(func():
		nodule_pos = $Container/PlayButton.global_position)
	$Container/SettingsButton.focus_entered.connect(func():
		nodule_pos = $Container/SettingsButton.global_position)
	$Container/QuitButton.focus_entered.connect(func():
		nodule_pos = $Container/QuitButton.global_position)
	
	$Container/PlayButton.mouse_entered.connect(func():
		nodule_pos = $Container/PlayButton.global_position)
	$Container/SettingsButton.mouse_entered.connect(func():
		nodule_pos = $Container/SettingsButton.global_position)
	$Container/QuitButton.mouse_entered.connect(func():
		nodule_pos = $Container/QuitButton.global_position)
	
	await get_tree().create_timer(0.55).timeout
	var _f = create_tween()
	_f.tween_property($Nodule, "modulate:a", 1.0, 0.2)

func _ready() -> void:
	set_up_nodule()
	
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
	await get_tree().process_frame
	$Container/PlayButton.grab_focus()

func _process(delta: float) -> void:
	$Nodule.global_position = lerp($Nodule.position, nodule_pos + Vector2(-24, 16), delta * 22)

func _on_play_button_down() -> void:
	get_tree().change_scene_to_file(LOADER_SCENE)

func _on_quit_button_down() -> void:
	get_tree().quit()

func _on_settings_button_down() -> void:
	if !$SettingsPane.is_open:
		$SettingsPane.open()
