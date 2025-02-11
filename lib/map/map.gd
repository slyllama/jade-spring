extends Node3D
# Map
# Base class for map functionalirt

var picking_disabled_objects: Array[StaticBody3D] = []

# Re-enable mouse event-disabled static bodies
func reset_picking_disabled_objects() -> void:
	for _n in picking_disabled_objects:
		_n.input_ray_pickable = true
	picking_disabled_objects = []

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_debug"):
		Global.debug_enabled = !Global.debug_enabled
		Global.debug_toggled.emit()

func _ready() -> void:
	# Set initial state
	Global.safe_point = $SafePoint
	Global.debug_toggled.emit()
	Global.deco_pane_open = false # reset
	Global.dialogue_open = false # reset
	
	Global.command_sent.connect(func(cmd):
		if cmd == "/hidecrumbs":
			for _c in $CrumbHandler.get_children():
				_c.visible = false
				Global.announcement_sent.emit("((Hiding crumbs.))")
		elif cmd == "/showcrumbs":
			for _c in $CrumbHandler.get_children():
				_c.visible = true
				Global.announcement_sent.emit("((Showing crumbs.))"))
	
	# Apply settings
	SettingsHandler.setting_changed.connect(func(parameter):
		var _value = SettingsHandler.settings[parameter]
		match parameter:
			"window_mode": Utilities.set_window_mode(_value)
			"volume": Utilities.set_master_vol()
			"music_vol": $Jukebox.volume_set = float(_value) * 0.34
			"bloom":
				if _value == "on": $Sky.environment.glow_enabled = true
				elif _value == "off": $Sky.environment.glow_enabled = false
			"orbit_sensitivity":
				# Ease orbit sensitivity, making it more precise for lower values
				Global.orbit_sensitivity_multiplier = ease(0.01 + _value, 1.8)
			"fps_cap":
				if str(_value) == "30": Engine.set_max_fps(30)
				elif str(_value) == "60": Engine.set_max_fps(60)
				else: Engine.set_max_fps(0)
			"vsync":
				if _value == "on": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
				else: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	)
	SettingsHandler.refresh(["volume"])
	
	Global.cursor_enabled.connect(func(data):
		await get_tree().process_frame
		var _cursor = Cursor3D.new()
		add_child(_cursor)
		_cursor.activate(data))
	
	# Prevent static bodies from consuming mouse input while decoration
	# manipulation is active (so the arrows can still be dragged even if the
	# decoration is, say, underground)
	Global.adjustment_started.connect(func():
		for _n in Utilities.get_all_children(self):
			if _n is StaticBody3D:
				picking_disabled_objects.append(_n)
				_n.input_ray_pickable = false)
	
	Global.adjustment_applied.connect(reset_picking_disabled_objects)
	Global.adjustment_canceled.connect(reset_picking_disabled_objects)
	
	# Reset (if coming from main menu after a previous session)
	# We add 'immobile' as FXList won't check Global.can_move if it isn't there
	Global.current_effects = [ "immobile" ]
	await get_tree().process_frame
	
	# Add some effects (like weeds)
	if "weeds" in Save.data: # protection for older dev saves
		for _w in Save.data.weeds:
			Global.add_qty_effect("weed")
	
	Global.can_move = true
	
	# Fade volume in and play music after a short delay
	await get_tree().create_timer(0.5).timeout
	var vol_tween = create_tween()
	vol_tween.tween_method(
		Utilities.set_master_vol, 0.0, Utilities.get_user_vol(), 1.0)
	await get_tree().create_timer(4.0).timeout
