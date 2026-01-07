class_name HUDScript extends CanvasLayer

const FADE = 0.6 # faded buttons will have this alpha value

func _render_fps() -> String: # pretty formatting of FPS values
	var color = "green"
	var _fps = Engine.get_frames_per_second()
	if _fps < 60:
		color = "yellow"
	elif _fps < 10:
		color = "red"
	return("[color=" + color + "]" + str(_fps) + "fps[/color]")

# Print information about crumbs spawned into the map
func _render_crumb_debug() -> String:
	if Global.crumb_handler == null:
		return("")
	var _s = ""
	if Global.current_crumb != null:
		_s += ("\n[color=yellow]Proximal crumb: "
			+ str(Global.current_crumb.name) + "[/color]")
	if Global.current_gadget != null:
		_s += ("\n[color=yellow]Proximal Gadget: "
			+ str(Global.current_gadget.name) + "[/color]")
	return(_s)

func get_debug_has_focus() -> bool:
	return($TopLevel/DebugEntry.has_focus())

func _show_int() -> void: # show the interaction indicator
	if Global.tool_mode == Global.TOOL_MODE_NONE:
		$InteractEnter.play()
	var fade_tween = create_tween()
	fade_tween.tween_property($InteractIndicator, "modulate:a", 0.9, 0.1)
func _hide_int() -> void: # hide the interaction indicator
	var fade_tween = create_tween()
	fade_tween.tween_property($InteractIndicator, "modulate:a", 0.0, 0.1)

func _debug_cmd_gain_focus() -> void:
	$TopLevel/DebugEntry.grab_focus() 
	$TopLevel/DebugEntry.modulate.a = 1.0
	Global.popup_open = true
	Global.can_move = false
	Global.action_cam_disable.emit()

func _debug_cmd_lose_focus(clear = false) -> void:
	if clear:
		$TopLevel/DebugEntry.text = ""
	$TopLevel/DebugEntry.release_focus()
	$TopLevel/DebugEntry.modulate.a = (200.0/255.0)
	
	await get_tree().process_frame
	Global.popup_open = false
	Global.action_cam_enable.emit()
	# Only allow movement if it wasn't forbidden prior
	if !Global.dialogue_open and !Global.tool_mode == Global.TOOL_MODE_FISH:
		Global.can_move = true

func proc_story() -> void:
	if Save.data.story_point == "game_start":
		$Toolbox.visible = false
	else:
		$Toolbox.visible = true
	
	if Save.data.story_point == "pick_weeds":
		Global.play_hint("tasks", { 
				"title": "Ratchet's Tasks",
				"arrow": "left",
				"anchor_preset": Control.LayoutPreset.PRESET_TOP_RIGHT,
				"text": "The tasks Ratchet has for you will be presented here, along with your total progress in cleaning the garden!"
			}, Utilities.get_screen_center(
				Vector2(get_viewport().size.x / Global.retina_scale * 0.5 - 460,
				40 - get_viewport().size.y / Global.retina_scale * 0.5)), true)

# Set whether the effects list registers mouse inputs or ignores them
func set_fx_pickable(state := true) -> void:
	if state: $FXList.mouse_filter = Control.MOUSE_FILTER_PASS
	else: $FXList.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if $TopLevel/DebugEntry.has_focus():
			_debug_cmd_lose_focus(true)
			return
		if (!Global.in_exclusive_ui and !Global.deco_pane_open
			and !$TopLevel/SettingsPane.is_open):
			$TopLevel/SettingsPane.open()
	
	if Input.is_action_just_pressed("debug_cmd"):
		if !Global.debug_enabled or !Global.debug_allowed or Global.design_pane_open: return
		await get_tree().process_frame
		if !$TopLevel/DebugEntry.has_focus():
			# Select the command line for entry
			_debug_cmd_gain_focus()
		else:
			# Send text and clear the command line
			Global.last_command = $TopLevel/DebugEntry.text
			Global.command_sent.emit($TopLevel/DebugEntry.text)
			_debug_cmd_lose_focus(true)
	
	if Input.is_action_just_pressed("debug_cmd_slash"):
		if !Global.debug_allowed: return
		if !Global.debug_enabled: # enable debug first, if it hasn't been already
			Global.debug_enabled = true
			Global.debug_toggled.emit()
		if !$TopLevel/DebugEntry.has_focus():
			_debug_cmd_gain_focus()
	
	if Input.is_action_just_pressed("last_cmd"):
		if !Global.debug_allowed: return
		Global.command_sent.emit(Global.last_command)
	
	# Fill the command line with the last-used command
	if Input.is_action_just_pressed("debug_fill_last_cmd"):
		if !Global.debug_allowed: return
		if !Global.debug_enabled: # enable debug first, if it hasn't been already
			Global.debug_enabled = true
			Global.debug_toggled.emit()
		_debug_cmd_gain_focus()
		$TopLevel/DebugEntry.text = Global.last_command
		await get_tree().process_frame
		$TopLevel/DebugEntry.set_caret_column(100)
	
	# Toggle HUD visibility (good for promotional screenshots)
	if Input.is_action_just_pressed("toggle_hud"):
		if visible:
			hide_hud()
		else:
			show_hud()

func show_hud() -> void:
	if visible: return
	if Save.data.story_point != "game_start":
		$Toolbox.visible = true
	if Global.debug_enabled:
		$TopLevel/DebugEntry.visible = true
	visible = true

func hide_hud() -> void:
	if !visible: return
	$Toolbox.visible = false
	$TopLevel/DebugEntry.visible = false
	visible = false

# Fade the game to black
signal fade_out_complete
func fade_out() -> void:
	$TopLevel/FG.visible = true
	$TopLevel/FG.modulate.a = 0.0
	var _fade_tween = create_tween()
	_fade_tween.tween_property($TopLevel/FG, "modulate:a", 1.0, 0.3)
	_fade_tween.tween_callback(fade_out_complete.emit)

func fade_in() -> void:
	$TopLevel/FG.visible = true
	$TopLevel/FG.modulate.a = 1.0
	var _fade_tween = create_tween()
	_fade_tween.tween_property($TopLevel/FG, "modulate:a", 0.0, 0.3)
	_fade_tween.tween_callback(func():
		$TopLevel/FG.visible = false)

func _ready() -> void:
	$TopLevel/SettingsPane/Container/SC/Contents/ResetBox.visible = false
	Global.hud = self # reference
	
	# Interaction connections
	Global.bug_crumb_entered.connect(_show_int)
	Global.bug_crumb_left.connect(_hide_int)
	Global.weed_crumb_entered.connect(_show_int)
	Global.weed_crumb_left.connect(_hide_int)
	Global.dragonvoid_crumb_entered.connect(_show_int)
	Global.dragonvoid_crumb_left.connect(_hide_int)
	Global.generic_area_entered.connect(_show_int)
	Global.generic_area_left.connect(_hide_int)
	Global.deco_pane_closed.connect($DecoPane.close)
	Global.deco_pane_opened.connect($DecoPane.open)
	Global.fishing_started.connect(_hide_int)
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/quit":
			get_tree().quit()
		elif _cmd == "/teststorypanel":
			Global.summon_story_panel.emit({
				"title": "((Test Story Panel))",
				"description": "((Description for the test story panel.))"
			}))
	
	Global.debug_toggled.connect(func():
		if visible:
			$TopLevel/DebugEntry.visible = Global.debug_enabled
		$Debug.visible = Global.debug_enabled)
	
	Global.summon_story_panel.connect(func(data):
		if !"description" in data or !"title" in data: return
		
		var _sp = load("res://lib/story_panel/story_panel.tscn").instantiate()
		add_child(_sp)
		if "sticker" in data: _sp.open(data.title, data.description, data.sticker)
		else: _sp.open(data.title, data.description)
		$InteractIndicator.mouse_filter = Control.MOUSE_FILTER_IGNORE)
	
	Global.close_story_panel.connect(func():
		$InteractIndicator.mouse_filter = Control.MOUSE_FILTER_STOP)
	
	# Configure corner buttons to light up when hovered over
	for _n in $CornerButtons.get_children():
		if _n is TextureButton:
			_n.modulate.a = FADE
			_n.mouse_entered.connect(func(): _n.modulate.a = 1.0)
			_n.mouse_exited.connect(func(): _n.modulate.a = FADE)
			_n.button_down.connect(Global.click_sound.emit)
	
	$InteractIndicator.modulate.a = 0.0
	$TopLevel/FG.visible = true
	$Underlay.queue_free()
	
	#await get_tree().create_timer(0.51).timeout
	await Global.decorations_loaded
	
	var _fade_tween = create_tween()
	_fade_tween.tween_property($TopLevel/FG, "modulate:a", 0.0, 0.5)
	_fade_tween.tween_callback(func():
		$TopLevel/FG.visible = false)
	
	# Opening story panel (if the story hasn't been advanced)
	if Save.data.story_point == "game_start":
		Global.summon_story_panel.emit(Save.STORY_POINT_SCRIPT["game_start"])
	
	Save.story_advanced.connect(proc_story)
	proc_story()

func _process(_delta: float) -> void:
	if Global.tool_mode != Global.TOOL_MODE_NONE:
		if $InteractIndicator.visible:
			$InteractIndicator.visible = false
	else:
		if !$InteractIndicator.visible:
			$InteractIndicator.visible = true
	
	#region Debug printing
	if Global.debug_enabled:
		$Debug.text = "[right]"
		$Debug.text += _render_fps()
		#$Debug.text += "\n(" + Utilities.fmt_vec3(Global.player_position) + ")"
		$Debug.text += (" ("
			+ str(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)) + ")")
		$Debug.text += "\n"
		$Debug.text += ("\n" + str(Global.tool_identities[Global.tool_mode]))
		#$Debug.text += ("\n" + str(Utilities.fmt_vec3(Global.player_position)))
		$Debug.text += ("\nSave.STORY_POINTS." + str(Save.data.story_point))
		$Debug.text += "\n"
		if Global.in_exclusive_ui: $Debug.text += ("\n[color=yellow]Exclusive UI[/color]")
		
		$Debug.text += _render_crumb_debug()
		
		if Global.deco_selection_array.size() > 0:
			for _i in Global.deco_selection_array:
				$Debug.text += "\n[color=cyan]    " + str(_i.node.id) + "[/color]"
		$Debug.text += "[/right]"
	#endregion

func _on_settings_down() -> void:
	if !$TopLevel/SettingsPane.is_open: $TopLevel/SettingsPane.open()
	else: $TopLevel/SettingsPane.close()

func _on_close_button_down() -> void:
	get_tree().quit() # TODO: temporary?

func _on_debug_entry_focus_exited() -> void:
	_debug_cmd_lose_focus()

func _on_debug_entry_focus_entered() -> void:
	_debug_cmd_gain_focus()

func _on_interact_indicator_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		var _i = InputEventAction.new()
		_i.action = "interact"
		
		_i.pressed = true
		Input.parse_input_event(_i)
		_i.pressed = false
		
		# Not sure why this only works when you do it twice, but it does
		Input.action_press("interact")
		Input.action_release("interact")

func _on_camera_button_down() -> void:
	Global.command_sent.emit("/screenshot")

func _on_camera_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("right_click"):
		if !DirAccess.dir_exists_absolute("user://screenshots"):
			DirAccess.make_dir_absolute("user://screenshots")
		OS.shell_open(ProjectSettings.globalize_path("user://screenshots"))

func _on_safe_point_button_down() -> void:
	Global.go_to_safe_point()

func _on_debug_entry_mouse_entered() -> void:
	Global.mouse_in_ui = true

func _on_debug_entry_mouse_exited() -> void:
	Global.mouse_in_ui = false

func _on_report_bug_button_down() -> void:
	OS.shell_open("https://slyllama.net/ticket/")
