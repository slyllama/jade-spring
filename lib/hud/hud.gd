extends CanvasLayer

@export var safe_point: Marker3D

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
			+ str(Global.current_crumb) + "[/color]")
	return(_s)

func _show_int() -> void: # show the interaction indicator
	var fade_tween = create_tween()
	fade_tween.tween_property($InteractIndicator, "modulate:a", 1.0, 0.1)
func _hide_int() -> void: # hide the interaction indicator
	var fade_tween = create_tween()
	fade_tween.tween_property($InteractIndicator, "modulate:a", 0.0, 0.1)

func _debug_cmd_gain_focus() -> void:
	$TopLevel/DebugEntry.grab_focus() 
	$TopLevel/DebugEntry.modulate.a = 1.0
	Global.popup_open = true
	Global.can_move = false

func _debug_cmd_lose_focus(clear = false) -> void:
	if clear:
		$TopLevel/DebugEntry.text = ""
	$TopLevel/DebugEntry.release_focus()
	$TopLevel/DebugEntry.modulate.a = (200.0/255.0)
	
	await get_tree().process_frame
	Global.popup_open = false
	# Only allow movement if it wasn't forbidden prior
	if !Global.tool_mode == Global.TOOL_MODE_FISH:
		Global.can_move = true

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_debug_cmd_lose_focus(true)
	
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
		if !$TopLevel/DebugEntry.has_focus():
			_debug_cmd_gain_focus()
	
	# Fill the command line with the last-used command
	if Input.is_action_just_pressed("ui_up"):
		_debug_cmd_gain_focus()
		$TopLevel/DebugEntry.text = Global.last_command
	
	# Toggle HUD visibility (good for promotional screenshots)
	if Input.is_action_just_pressed("toggle_hud"):
		if visible: visible = false
		else: visible = true

func _ready() -> void:
	# Interaction connections
	Global.bug_crumb_entered.connect(_show_int)
	Global.bug_crumb_left.connect(_hide_int)
	Global.weed_crumb_entered.connect(_show_int)
	Global.weed_crumb_left.connect(_hide_int)
	Global.generic_area_entered.connect(_show_int)
	Global.generic_area_left.connect(_hide_int)
	
	Global.fishing_started.connect(_hide_int)
	
	$InteractIndicator.modulate.a = 0.0
	$FG.visible = true
	$Underlay.queue_free() # clear debugging component
	Global.deco_pane_closed.connect($DecoPane.close)
	Global.deco_pane_opened.connect($DecoPane.open)
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/quit":
			get_tree().quit()
		elif _cmd == "/storypanel":
			var _sp = load("res://lib/story_panel/story_panel.tscn").instantiate()
			add_child(_sp)
			_sp.open()
	)
	
	Global.debug_toggled.connect(func():
		$TopLevel/DebugEntry.visible = Global.debug_enabled
		$Debug.visible = Global.debug_enabled)
	
	# Configure corner buttons to light up when hovered over
	for _n in $CornerButtons.get_children():
		if _n is TextureButton:
			_n.modulate.a = FADE
			_n.mouse_entered.connect(func(): _n.modulate.a = 1.0)
			_n.mouse_exited.connect(func(): _n.modulate.a = FADE)
			_n.button_down.connect(Global.click_sound.emit)
	
	await get_tree().process_frame
	var _fade_tween = create_tween()
	_fade_tween.tween_property($FG, "modulate:a", 0.0, 0.5)
	_fade_tween.tween_callback($FG.queue_free)
	
	Global.debug_enabled = true
	Global.debug_toggled.emit()

func _process(_delta: float) -> void:
	if Global.tool_mode != Global.TOOL_MODE_NONE:
		if $InteractIndicator.visible:
			$InteractIndicator.visible = false
	else:
		if !$InteractIndicator.visible:
			$InteractIndicator.visible = true
	
	# Debug stuff
	$Debug.text = "[right]"
	$Debug.text += _render_fps()
	$Debug.text += ("\nPrimitives: "
		+ str(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)))
	$Debug.text += "\n"
	$Debug.text += ("\nTool mode: " + str(Global.tool_identities[Global.tool_mode]))
	$Debug.text += ("\nFoliage count: " + str(Global.foliage_count))
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

func _on_settings_down() -> void:
	if !$TopLevel/SettingsPane.is_open: $TopLevel/SettingsPane.open()
	else: $TopLevel/SettingsPane.close()

func _on_wp_button_down() -> void:
	if safe_point != null:
		Global.move_player.emit(safe_point.global_position)
	else:
		Global.announcement_sent.emit(
			"((No safe point to teleport to!))")

func _on_close_button_down() -> void:
	get_tree().quit() # TODO: temporary?

func _on_debug_entry_focus_exited() -> void:
	_debug_cmd_lose_focus()

func _on_debug_entry_focus_entered() -> void:
	_debug_cmd_gain_focus()
