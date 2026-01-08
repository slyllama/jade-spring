extends "res://lib/ui_container/ui_container.gd"

func _update_fov_text() -> void:
	$Container/SC/Contents/FOV/Title.text = (
		$Container/SC/Contents/FOV.title
		+ " (" + str(SettingsHandler.get_fov_deg())
		+ Utilities.DEG + ")")

func open(silent = false) -> void:
	if !Save.is_at_story_point(Save.GIFT_STORY_POINT) or get_parent().name == "MainMenu":
		$Container/SC/Contents/ShowGift.visible = false
	
	super(silent)
	$PreventFocus.visible = false
	$Container/DoneResetBox/Done.grab_focus()
	Global.settings_open = true
	Global.settings_pane_opened.emit()
	Global.action_cam_disable.emit()
	
	await get_tree().process_frame
	$Container/SC/Contents/WindowMode.selected_option = SettingsHandler.settings.window_mode
	$Container/SC/Contents/WindowMode.refresh()

func close() -> void:
	Global.settings_open = false
	$BindingsPane.close()
	if !get_tree().paused:
		Global.action_cam_enable.emit()
	SettingsHandler.save_to_file()
	super()

func _input(event: InputEvent) -> void:
	super(event)
	if Input.is_action_just_pressed("ui_cancel"):
		# Horrible sickening dark magic to prevent the settings pane closing
		# after escaping out of the debugging input field
		if get_parent().get_parent().has_method(&"get_debug_has_focus"):
			if get_parent().get_parent().get_debug_has_focus():
				return
		if is_open:
			await get_tree().process_frame
			close()

func _ready() -> void:
	super()
	var _scroll_bar: VScrollBar = $Container/SC.get_v_scroll_bar()
	_scroll_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	# Volume needs to be set independently because its setting update isn't
	# pinged on start (to prevent an awkward spike in volume)
	$Container/SC/Contents/Volume.set_value_silent(Utilities.get_user_vol())
	
	Global.summon_story_panel.connect(func(_data): close())
	
	Save.story_advanced.connect(func():
		if Save.is_at_story_point(Save.GIFT_STORY_POINT):
			$Container/SC/Contents/ShowGift.visible = true
			SettingsHandler.refresh(["window_mode"]))
	
	SettingsHandler.setting_changed.connect(func(_param):
		if _param == "fov":
			var _fov = SettingsHandler.settings.fov
			_update_fov_text())

func _on_save_press() -> void:
	close()

func _on_quit_button_down() -> void:
	if !Global.in_exclusive_ui:
		AudioServer.set_bus_volume_db(0, -80)
		Save.data.karma += Global.assigned_karma
		Global.design_handler.create_design_slot()
		Global.dismiss_hints()
		Global.command_sent.emit("/savedata")
		SteamHandler.store_stats()
		close()
		
		Global.hud.fade_out()
		await Global.hud.fade_out_complete
		get_tree().change_scene_to_file("res://lib/main_menu/mm_loader/mm_loader.tscn")

func _process(delta: float) -> void:
	super(delta)
	# Prevent settings buttons from gaining focus while orbiting
	
	if is_open:
		if get_window().gui_get_hovered_control() is HSlider:
			if $Container/SC.mouse_filter == MOUSE_FILTER_PASS:
				$Container/SC.mouse_filter = MOUSE_FILTER_IGNORE
		else:
			if $Container/SC.mouse_filter == MOUSE_FILTER_IGNORE:
				$Container/SC.mouse_filter = MOUSE_FILTER_PASS
	
	if Global.tool_mode != Global.TOOL_MODE_NONE: $Container/SC/Contents/Bindings.disabled = true
	else: $Container/SC/Contents/Bindings.disabled = false
	
	if Global.camera_orbiting:
		if !$PreventFocus.visible:
			$PreventFocus.visible = true
	else:
		if $PreventFocus.visible:
			$PreventFocus.visible = false

func _on_bindings_button_down() -> void:
	if Global.tool_mode != Global.TOOL_MODE_NONE:
		return
	if !$BindingsPane.is_open: $BindingsPane.open()
	else: $BindingsPane.close()

func _on_bindings_pane_closed() -> void: 
	moveable = true
func _on_bindings_pane_opened() -> void:
	moveable = false
func _on_reset_button_down() -> void:
	SettingsHandler.reset()

func _on_gp_low_button_down() -> void:
	SettingsHandler.update("aa", "disabled")
	SettingsHandler.update("foliage_density", "low")
	SettingsHandler.update("fps_cap", "60")
	SettingsHandler.update("bloom", "off")
	SettingsHandler.update("shadows", "low")
	
	SettingsHandler.update("saturation", 0.65)
	SettingsHandler.update("brightness", 1.0)
	SettingsHandler.save_to_file()

func _on_gp_normal_button_down() -> void:
	SettingsHandler.update("aa", "msaa_(4x)")
	SettingsHandler.update("foliage_density", "high")
	SettingsHandler.update("fps_cap", "60")
	SettingsHandler.update("bloom", "on")
	SettingsHandler.update("shadows", "medium")
	
	SettingsHandler.update("saturation", 0.5)
	SettingsHandler.update("brightness", 0.5)
	SettingsHandler.save_to_file()

func _on_gp_high_button_down() -> void:
	SettingsHandler.update("aa", "msaa_(4x)_with_fxaa")
	SettingsHandler.update("foliage_density", "ultra")
	SettingsHandler.update("fps_cap", "60")
	SettingsHandler.update("bloom", "on")
	SettingsHandler.update("shadows", "high")
	
	SettingsHandler.update("saturation", 0.5)
	SettingsHandler.update("brightness", 0.5)
	SettingsHandler.save_to_file()

func _on_rsc_button_down() -> void: # reset shader cache
	Utilities.remove_recursive("user://shader_cache")
	Utilities.remove_recursive("user://vulkan")
	await get_tree().process_frame
	get_tree().quit()
