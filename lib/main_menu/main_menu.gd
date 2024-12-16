extends CanvasLayer

const LOADER_SCENE = "res://lib/loader/loader.tscn"
const DECO_DATA_PATH = "user://deco.dat"
var rng = RandomNumberGenerator.new()

@onready var focus: Button
var can_interact = true
var ngc_open = false # new game container open
var _light_ray_target_alpha = 0.01

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
	
	await get_tree().create_timer(0.12).timeout
	var _f = create_tween()
	_f.tween_property($Nodule, "modulate:a", 1.0, 0.2)

func _set_title_card_pos() -> void:
	$TitleCard.global_position = $Container/Padding.global_position + Vector2(165, -20)

# Fade and transition into loader scene or custom scene (if it is set)
func play() -> void:
	$FG.visible = true
	$FG.modulate.a = 0.0
	can_interact = false
	
	var fade_tween = create_tween()
	fade_tween.tween_property($FG, "modulate:a", 1.0, 0.35)
	var music_tween = create_tween()
	music_tween.tween_property(
		$Music, "volume_db", -80.0, 0.55).set_ease(Tween.EASE_OUT)
	music_tween.set_parallel()
	
	fade_tween.tween_callback(func():
		get_tree().change_scene_to_file(LOADER_SCENE))

func _ready() -> void:
	$LightRay.modulate.a = 0.01
	$FG.visible = true
	$FG.modulate.a = 1.0
	$SettingsPane/Container/Quit.queue_free()
	set_up_nodule()
	await get_tree().process_frame
	
	var fade_tween = create_tween()
	fade_tween.tween_property($FG, "modulate:a", 0.0, 0.55)
	fade_tween.tween_callback(func():
		if can_interact:
			$FG.visible = false)
	
	AudioServer.set_bus_volume_db(0, -80)
	SettingsHandler.setting_changed.connect(func(parameter):
		var _value = SettingsHandler.settings[parameter]
		match parameter:
			"window_mode": Utilities.set_window_mode(_value)
			"volume": Utilities.set_master_vol()
			"music_vol": $Music.volume_db = linear_to_db(
				clamp(float(_value) * 0.55, 0.0, 1.0))
	)
	
	get_window().size_changed.connect(_set_title_card_pos)
	
	SettingsHandler.refresh(["volume"])
	await get_tree().process_frame
	_set_title_card_pos()
	
	# Only show the 'continue' button if a save exists
	if FileAccess.file_exists(DECO_DATA_PATH):
		$Container/ContinueButton.grab_focus()
	else:
		$Container/ContinueButton.visible = false
		$Container/PlayButton.grab_focus()
	
	$Nodule.global_position = focus.global_position + Vector2(0, 16)
	
	var vol_tween = create_tween()
	vol_tween.tween_method(
		Utilities.set_master_vol, 0.0, Utilities.get_user_vol(), 1.0)
	await vol_tween.finished
	$Music.play()

func _process(delta: float) -> void:
	$LightRay.modulate.a = lerp($LightRay.modulate.a, _light_ray_target_alpha, delta * 6.0)
	
	if !can_interact or ngc_open: return
	if focus == null: return
	$Nodule.global_position = lerp(
		$Nodule.position, focus.global_position + Vector2(0, 16), delta * 22)

func _on_play_button_down() -> void:
	if !can_interact or ngc_open: return
	$NewGameContainer.open()
	ngc_open = true

func _on_quit_button_down() -> void:
	if !can_interact or ngc_open: return
	get_tree().quit()

func _on_settings_button_down() -> void:
	if !can_interact or ngc_open: return
	if !$SettingsPane.is_open:
		$SettingsPane.open()

func _on_continue_button_down() -> void:
	if !can_interact or ngc_open: return
	Global.start_params.new_save = false
	play()

func _on_ngc_closed() -> void:
	ngc_open = false

func _on_new_game_button_pressed() -> void:
	Save.reset()
	
	ngc_open = false
	$NewGameContainer.close()
	Global.start_params.new_save = true
	play()

func _on_timer_timeout() -> void:
	_light_ray_target_alpha = 0.02 + 0.03 * rng.randf()

func _on_settings_pane_closed() -> void:
	$Container/SettingsButton.grab_focus()
