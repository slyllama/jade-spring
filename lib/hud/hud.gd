extends CanvasLayer

const QuitConfirmation = preload("res://lib/hud/quit_confirmation/quit_confirmation.tscn")
const FADE = 0.6 # faded buttons will have this alpha value

func _render_fps() -> String: # pretty formatting of FPS values
	var color = "green"
	var _fps = Engine.get_frames_per_second()
	if _fps < 60:
		color = "yellow"
	elif _fps < 10:
		color = "red"
	return("[color=" + color + "]" + str(_fps) + "fps[/color]")

func _ready() -> void:
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
	# Debug stuff
	$Debug.text = _render_fps()
	$Debug.text += "\nPrimitives: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	$Debug.text += "\n"
	$Debug.text += ("\nTool mode: " + str(Global.tool_identities[Global.tool_mode]))
	$Debug.text += ("\nFoliage count: " + str(Global.foliage_count))
	if Global.active_decoration != null:
		$Debug.text += ("\n[color=yellow]Active decoration: " + str(Global.active_decoration) + "[/color]")

func _on_settings_down() -> void:
	if !$SettingsPane.is_open: $SettingsPane.open()
	else: $SettingsPane.close()

func _on_close_pressed() -> void:
	if !Global.in_exclusive_ui:
		var _qc = QuitConfirmation.instantiate()
		add_child(_qc)
