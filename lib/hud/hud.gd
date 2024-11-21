extends CanvasLayer

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
	var _s = "\n" + str(Global.crumb_data)
	if Global.current_crumb != null:
		_s += ("\n[color=yellow]Proximal crumb: " + str(Global.current_crumb) + "[/color]")
	return(_s)

func _show_int() -> void: # show the interaction indicator
	var fade_tween = create_tween()
	fade_tween.tween_property($InteractIndicator, "modulate:a", 1.0, 0.1)
func _hide_int() -> void: # hide the interaction indicator
	var fade_tween = create_tween()
	fade_tween.tween_property($InteractIndicator, "modulate:a", 0.0, 0.1)

func _input(_event: InputEvent) -> void:
	# Toggle HUD visibility (good for promotional screenshots)
	if Input.is_action_just_pressed("toggle_hud"):
		if visible:
			visible = false
		else:
			visible = true

func _ready() -> void:
	Global.bug_crumb_entered.connect(_show_int)
	Global.bug_crumb_left.connect(_hide_int)
	Global.fishing_started.connect(_hide_int)
	Global.generic_area_entered.connect(_show_int)
	Global.generic_area_left.connect(_hide_int)
	
	$InteractIndicator.modulate.a = 0.0
	$FG.visible = true
	$Underlay.queue_free() # clear debugging component
	Global.deco_pane_closed.connect($DecoPane.close)
	Global.deco_pane_opened.connect($DecoPane.open)
	
	Global.debug_toggled.connect(func():
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
	if !$SettingsPane.is_open: $SettingsPane.open()
	else: $SettingsPane.close()
