extends CanvasLayer

const LOADER_SCENE = "res://lib/loader/loader.tscn"

@onready var focus: Button

# Connections and tweens to make the focus nodule look right
func set_up_nodule() -> void:
	$Nodule.modulate.a = 0.0
	
	$Container/PlayButton.focus_entered.connect(func():
		focus = $Container/PlayButton)
	$Container/SettingsButton.focus_entered.connect(func():
		focus = $Container/SettingsButton)
	$Container/QuitButton.focus_entered.connect(func():
		focus = $Container/QuitButton)
	$Container/ContinueButton.focus_entered.connect(func():
		focus = $Container/ContinueButton)
	
	$Container/PlayButton.mouse_entered.connect(func():
		focus = $Container/PlayButton)
	$Container/SettingsButton.mouse_entered.connect(func():
		focus = $Container/SettingsButton)
	$Container/QuitButton.mouse_entered.connect(func():
		focus = $Container/QuitButton)
	$Container/ContinueButton.mouse_entered.connect(func():
		focus = $Container/ContinueButton)
	
	await get_tree().create_timer(0.55).timeout
	var _f = create_tween()
	_f.tween_property($Nodule, "modulate:a", 1.0, 0.2)

func _set_title_card_pos() -> void:
	$TitleCard.global_position = $Container/Padding.global_position + Vector2(165, -40)

func _ready() -> void:
	set_up_nodule()
	$SettingsPane/Container/Quit.queue_free()
	
	AudioServer.set_bus_volume_db(0, -80)
	SettingsHandler.setting_changed.connect(func(parameter):
		var _value = SettingsHandler.settings[parameter]
		match parameter:
			"window_mode":
				if _value == "full_screen": get_window().mode = Window.MODE_FULLSCREEN
				elif _value == "maximized": get_window().mode = Window.MODE_MAXIMIZED
				else: get_window().mode = Window.MODE_WINDOWED
			"volume": Utilities.set_master_vol()
			"music_vol": $Music.volume_db = linear_to_db(
				clamp(float(_value) * 0.55, 0.0, 1.0))
	)
	
	get_window().size_changed.connect(_set_title_card_pos)
	
	SettingsHandler.refresh(["volume"])
	await get_tree().process_frame
	_set_title_card_pos()
	$Container/ContinueButton.grab_focus()
	
	var vol_tween = create_tween()
	vol_tween.tween_method(Utilities.set_master_vol, 0.0, Utilities.get_user_vol(), 1.0)
	await vol_tween.finished
	$Music.play()

func _process(delta: float) -> void:
	if focus == null: return
	$Nodule.global_position = lerp(
		$Nodule.position, focus.global_position + Vector2(-17, 16), delta * 22)

func _on_play_button_down() -> void:
	Global.start_params.new_save = true
	get_tree().change_scene_to_file(LOADER_SCENE)

func _on_quit_button_down() -> void:
	get_tree().quit()

func _on_settings_button_down() -> void:
	if !$SettingsPane.is_open:
		$SettingsPane.open()

func _on_continue_button_down() -> void:
	Global.start_params.new_save = false
	get_tree().change_scene_to_file(LOADER_SCENE)
