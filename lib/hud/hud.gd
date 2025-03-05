extends CanvasLayer

const FADE = 0.6 # faded buttons will have this alpha value
const StoryPanel = preload("res://lib/story_panel/story_panel.tscn")

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
			+ str(Global.current_crumb) + "[/color]")
	return(_s)

func _show_int() -> void: # show the interaction indicator
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

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_debug_cmd_lose_focus(true)
		if (!Global.in_exclusive_ui and !Global.deco_pane_open
			and !$TopLevel/SettingsPane.is_open):
			$TopLevel/SettingsPane.open()
	
	if Input.is_action_just_pressed("debug_cmd"):
		if !Global.debug_enabled: return
		
		if !$TopLevel/DebugEntry.has_focus():
			# Select the command line for entry
			_debug_cmd_gain_focus()
		else:
			# Send text and clear the command line
			Global.last_command = $TopLevel/DebugEntry.text
			Global.command_sent.emit($TopLevel/DebugEntry.text)
			_debug_cmd_lose_focus(true)
	
	if Input.is_action_just_pressed("debug_cmd_slash"):
		if !Global.debug_enabled: # enable debug first, if it hasn't been already
			Global.debug_enabled = true
			Global.debug_toggled.emit()
		if !$TopLevel/DebugEntry.has_focus():
			_debug_cmd_gain_focus()
	
	# Fill the command line with the last-used command
	if Input.is_action_just_pressed("ui_up"):
		_debug_cmd_gain_focus()
		$TopLevel/DebugEntry.text = Global.last_command
	
	# Toggle HUD visibility (good for promotional screenshots)
	if Input.is_action_just_pressed("toggle_hud"):
		if visible:
			$Toolbox.visible = false
			$TopLevel/DebugEntry.visible = false
			visible = false
		else:
			if Save.data.story_point != "game_start":
				$Toolbox.visible = true
			if Global.debug_enabled:
				$TopLevel/DebugEntry.visible = true
			visible = true
func _ready() -> void:
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
		elif _cmd == "/storypanel":
			var _sp = StoryPanel.instantiate()
			add_child(_sp)
			_sp.open())
	
	Global.debug_toggled.connect(func():
		if visible:
			$TopLevel/DebugEntry.visible = Global.debug_enabled
		$Debug.visible = Global.debug_enabled)
	
	Global.summon_story_panel.connect(func(data):
		if !"description" in data or !"title" in data: return
		
		var _sp = StoryPanel.instantiate()
		add_child(_sp)
		if "sticker" in data: _sp.open(data.title, data.description, data.sticker)
		else: _sp.open(data.title, data.description))
	
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
	
	await get_tree().create_timer(0.51).timeout
	var _fade_tween = create_tween()
	_fade_tween.tween_property($TopLevel/FG, "modulate:a", 0.0, 0.5)
	_fade_tween.tween_callback($TopLevel/FG.queue_free)
	
	# Opening story panel (if the story hasn't been advanced)
	if Save.data.story_point == "game_start":
		Global.summon_story_panel.emit(Save.STORY_POINT_SCRIPT["game_start"])
	
	Save.story_advanced.connect(proc_story)
	proc_story()
	
	#Global.debug_enabled = true
	#Global.debug_toggled.emit()

func _process(_delta: float) -> void:
	if Global.tool_mode != Global.TOOL_MODE_NONE:
		if $InteractIndicator.visible:
			$InteractIndicator.visible = false
	else:
		if !$InteractIndicator.visible:
			$InteractIndicator.visible = true
	
	#region Debug printing
	$Debug.text = "[right]"
	$Debug.text += _render_fps()
	$Debug.text += "\n(" + Utilities.fmt_vec3(Global.player_position) + ")"
	$Debug.text += ("\nPrimitives: "
		+ str(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)))
	$Debug.text += "\n"
	$Debug.text += ("\nTool mode: " + str(Global.tool_identities[Global.tool_mode]))
	$Debug.text += ("\nFoliage count: " + str(Global.foliage_count))
	$Debug.text += ("\nStory step: " + str(Save.data.story_point))
	$Debug.text += ("\nIn exclusive UI: " + str(Global.in_exclusive_ui))
	if Global.mouse_3d_position != Utilities.BIGVEC3:
		$Debug.text += ("\n[color=yellow]Cursor 3D position: "
			+ str(Utilities.fmt_vec3(Global.mouse_3d_position)) + "[/color]")
	$Debug.text += "\n"
	if Global.decorations != []:
		$Debug.text += "\n" + str(Global.decorations.size()) + " decoration(s)"
	if Global.active_decoration != null:
		$Debug.text += ("\n[color=yellow]Active decoration: "
			+ str(Global.active_decoration) + "[/color]")
	if Global.queued_decoration != "none":
		$Debug.text += ("\n[color=yellow]Queued decoration: "
			+ str(Global.queued_decoration) + "[/color]")
	
	$Debug.text += _render_crumb_debug()
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
