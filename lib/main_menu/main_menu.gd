extends CanvasLayer

const SAVE_DATA_PATH = "user://save/save.dat"
const DECO_DATA_PATH = "user://save/deco.dat"
var LOADER_SCENE = "res://lib/loader/loader.tscn"
var rng = RandomNumberGenerator.new()

@onready var focus: Button
var can_interact = true
var ngc_open = false # new game container open

func backup_save_files() -> void:
	if !DirAccess.dir_exists_absolute("user://save/backup"):
		DirAccess.make_dir_absolute("user://save/backup")
	
	if FileAccess.file_exists(DECO_DATA_PATH):
		DirAccess.copy_absolute(DECO_DATA_PATH,
			"user://save/backup/deco-" + Version.VER + ".dat")
	if FileAccess.file_exists(SAVE_DATA_PATH):
		DirAccess.copy_absolute(SAVE_DATA_PATH, 
			"user://save/backup/save-" + Version.VER + ".dat")

# 0: valid
# 1: decoration file missing
# 2: decoration file invalid
func is_deco_file_valid() -> int:
	if FileAccess.file_exists(DECO_DATA_PATH):
		var _valid = true
		var file = FileAccess.open(DECO_DATA_PATH, FileAccess.READ)
		var _file_decos = file.get_var()
		file.close()
		for _d in _file_decos:
			if !"id" in _d: return(false)
			if !_d.id in Global.DecoData:
				return(2)
	else: return(1)
	return(0)

func _close_all_except(exceptions: Array[UIC]) -> void:
	var panes: Array[UIC] = [$SettingsPane, $SteamPane, $NewGameContainer, $CreditsContainer]
	for _p in panes:
		if !_p in exceptions:
			_p.close()

# Connections and tweens to make the focus nodule look right
func set_up_nodule() -> void:
	$Nodule.modulate.a = 0.0
	
	$Container/PlayButton.focus_entered.connect(func():
		$Swish.play()
		focus = $Container/PlayButton)
	$Container/CreditsButton.focus_entered.connect(func():
		$Swish.play()
		focus = $Container/CreditsButton)
	$Container/SettingsButton.focus_entered.connect(func():
		$Swish.play()
		focus = $Container/SettingsButton)
	$Container/QuitButton.focus_entered.connect(func():
		$Swish.play()
		focus = $Container/QuitButton)
	$Container/Box/ContinueButton.focus_entered.connect(func():
		$Swish.play()
		focus = $Container/Box/ContinueButton)
	$Container/AchievementsButton.focus_entered.connect(func():
		$Swish.play()
		focus = $Container/AchievementsButton)
	$Container/PlayButton.mouse_entered.connect(func():
		$Container/PlayButton.grab_focus()
		$Swish.play()
		focus = $Container/PlayButton)
	$Container/CreditsButton.mouse_entered.connect(func():
		$Container/CreditsButton.grab_focus()
		$Swish.play()
		focus = $Container/CreditsButton)
	$Container/SettingsButton.mouse_entered.connect(func():
		$Container/SettingsButton.grab_focus()
		$Swish.play()
		focus = $Container/SettingsButton)
	$Container/AchievementsButton.mouse_entered.connect(func():
		$Container/AchievementsButton.grab_focus()
		$Swish.play()
		focus = $Container/AchievementsButton)
	$Container/QuitButton.mouse_entered.connect(func():
		$Container/QuitButton.grab_focus()
		$Swish.play()
		focus = $Container/QuitButton)
	$Container/Box/ContinueButton.mouse_entered.connect(func():
		$Container/Box/ContinueButton.grab_focus()
		$Swish.play()
		focus = $Container/Box/ContinueButton)
	
	await get_tree().create_timer(0.12).timeout
	var _f = create_tween()
	_f.tween_property($Nodule, "modulate:a", 1.0, 0.2)

func _set_title_card_pos() -> void:
	update_graphic_position = true
	$TitleCard.global_position = $Container/Padding.global_position + Vector2(140, -20)

func _get_nodule_position() -> Vector2:
	return(Vector2(get_window().size.x / 2.0 / Global.retina_scale - 180.0, focus.global_position.y + 16))

# Fade and transition into loader scene or custom scene (if it is set)
func play() -> void:
	$FG.visible = true
	$FG.modulate.a = 0.0
	$Nodule.visible = false
	can_interact = false
	
	$SettingsPane.close()
	$SteamPane.close()
	$CreditsContainer.close()
	
	var fade_tween = create_tween()
	fade_tween.tween_property($FG, "modulate:a", 1.0, 0.35)
	var music_tween = create_tween()
	music_tween.tween_property(
		$Music, "volume_db", -80.0, 0.55).set_ease(Tween.EASE_OUT)
	music_tween.set_parallel()
	
	fade_tween.tween_callback(func():
		get_tree().change_scene_to_file(LOADER_SCENE))

func _input(_event: InputEvent) -> void:
	if !Global.debug_allowed: return
	if Input.is_action_just_pressed("enter"):
		var _f = get_window().gui_get_focus_owner()
		if _f is Button:
			_f.button_down.emit()
	if Input.is_action_just_pressed("debug_action"):
		if !can_interact or ngc_open: return
		Global.load_debug_next = true
		Global.map_name = "debug"
		play()

func _ready() -> void:
	$Raiqqo/Anim.play("fade_in")
	Global.camera_orbiting = false
	
	backup_save_files()
	if Global.debug_allowed: $DebugLabel.visible = true
	
	add_child(web_cooldown_timer)
	web_cooldown_timer.one_shot = true
	web_cooldown_timer.timeout.connect(func():
		on_web_cooldown = false)
	
	if !Engine.is_editor_hint() and DiscordRPC.get_is_discord_working():
		DiscordRPC.state = "In Menu"
		DiscordRPC.details = ""
		DiscordRPC.refresh()
	
	# Clear lingering effects which shouldn't be persistent
	for _fx in Global.current_effects:
		Global.current_effects.erase("discombobulator")
		Global.current_effects.erase("dv_charge")
	
	# Free the mouse if we've come from action camera mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if SteamHandler.steam_loaded:
		$Container/AchievementsButton.visible = true
	Steam.user_stats_received.connect(func(_i, _j, _k):
		$Container/AchievementsButton.visible = true
		await get_tree().process_frame
		$Container/SettingsButton.focus_neighbor_bottom = "../AchievementsButton"
		$Container/CreditsButton.focus_neighbor_top = "../AchievementsButton")
	
	$FG.visible = true
	$FG.modulate.a = 1.0
	$Container/Box/InvalidWarning.visible = false
	$SettingsPane/Container/Quit.queue_free()
	# Shader clearing only available from the main menu
	$SettingsPane/Container/SC/Contents/ResetShaderCache.visible = true
	
	set_up_nodule()
	await get_tree().process_frame
	
	var fade_tween = create_tween()
	fade_tween.tween_property($FG, "modulate:a", 0.0, 0.55)
	fade_tween.tween_callback(func():
		if can_interact:
			$Swish.volume_db = -5.0
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
	
	SettingsHandler.refresh(["volume", "draw_cap"])
	await get_tree().process_frame
	_set_title_card_pos()
	
	# Only show the 'continue' button if a save exists
	if FileAccess.file_exists(Save.FILE_PATH):
		if !Save.is_save_valid():
			$Container/Box/ContinueButton.disabled = true
			$Container/Box/InvalidWarning.visible = true
			$Container/PlayButton.grab_focus()
		else:
			$Container/PlayButton.focus_neighbor_top = "../Box/ContinueButton"
			$Container/Box/ContinueButton.grab_focus()
	else:
		$Container/Box.visible = false
		$Container/PlayButton.grab_focus()
	
	$Nodule.global_position = _get_nodule_position()
	
	var vol_tween = create_tween()
	vol_tween.tween_method(
		Utilities.set_master_vol, 0.0, Utilities.get_user_vol(), 1.0)
	await vol_tween.finished
	$Music.play()

var update_graphic_position = false # if true, will instantly update graphics (without lerping) on the next frame

func _process(delta: float) -> void:
	var _screen_center = get_viewport().size / 2.0 / Global.retina_scale
	var _mouse_offset = _screen_center - get_viewport().get_mouse_position()
	var _parallax_offset = _mouse_offset / Vector2(get_viewport().size) * Vector2(2.0, 0.6)
	
	if update_graphic_position:
		$Raiqqo.global_position = _screen_center + _parallax_offset * 3.0
		$RaiqqoFG.global_position = _screen_center + _parallax_offset * 5.5
		update_graphic_position = false
	
	$Raiqqo.global_position = lerp(
		$Raiqqo.global_position,
		_screen_center + _parallax_offset * 3.0,
		Utilities.critical_lerp(delta, 3.0))
	$RaiqqoFG.global_position = lerp(
		$RaiqqoFG.global_position,
		_screen_center + _parallax_offset * 5.5,
		Utilities.critical_lerp(delta, 4.0))
	
	var scale_diff = get_window().size.x / 1280.0 * 0.5 / Global.retina_scale
	$Raiqqo.scale = Vector2(scale_diff, scale_diff)
	$RaiqqoFG.scale = Vector2(scale_diff, scale_diff)
	
	if !can_interact: return
	if focus == null: return
	$Nodule.global_position = lerp(
		$Nodule.position,
		_get_nodule_position(),
		Utilities.critical_lerp(delta, 30.0))

func _on_play_button_down() -> void:
	if !can_interact: return
	Global.click_sound.emit()
	Global.map_name = "seitung"
	_close_all_except([$NewGameContainer])
	$NewGameContainer.open()
	ngc_open = true

func _on_quit_button_down() -> void:
	if !can_interact: return
	Global.click_sound.emit()
	get_tree().quit()

func _on_settings_button_down() -> void:
	if !can_interact: return
	_close_all_except([$SettingsPane])
	if !$SettingsPane.is_open:
		Global.click_sound.emit()
		$SettingsPane.open()

func _on_continue_button_down() -> void:
	if !can_interact: return
	Global.click_sound.emit()
	Global.map_name = "seitung"
	Global.start_params.new_save = false
	
	if is_deco_file_valid() < 2: play()
	elif is_deco_file_valid() == 2: $BrokenDecosContainer.open()

func _on_ngc_closed() -> void:
	ngc_open = false

func _on_new_game_button_pressed() -> void:
	Save.reset()
	
	ngc_open = false
	$NewGameContainer.close()
	Global.start_params.new_save = true
	play()

func _on_settings_pane_closed() -> void:
	pass
	#$Container/SettingsButton.grab_focus()

func _on_folder_button_down() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://save"))

func _on_achievements_button_button_down() -> void:
	if !can_interact: return
	_close_all_except([$SteamPane])
	$SteamPane.open()

func _on_credits_button_button_down() -> void:
	if !can_interact: return
	_close_all_except([$CreditsContainer])
	$CreditsContainer.open()

@onready var web_cooldown_timer = Timer.new()
var on_web_cooldown = false
const WEB_COOLDOWN = 0.35

func _on_logo_gui_input(_event: InputEvent) -> void:
	if on_web_cooldown: return
	if Input.is_action_just_pressed("left_click"):
		on_web_cooldown = true
		web_cooldown_timer.start()
		OS.shell_open("https://slyllama.net/")

func _on_broken_decos_container_continued() -> void:
	Global.map_name = "seitung"
	Global.start_params.new_save = false
	play()
