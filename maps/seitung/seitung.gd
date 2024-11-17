extends Node3D

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
	# Apply settings
	Global.debug_toggled.emit()
	
	SettingsHandler.setting_changed.connect(func(parameter):
		var _value = SettingsHandler.settings[parameter]
		match parameter:
			"window_mode":
				if _value == "full_screen": get_window().mode = Window.MODE_FULLSCREEN
				elif _value == "maximized": get_window().mode = Window.MODE_MAXIMIZED
				else: get_window().mode = Window.MODE_WINDOWED
			"foliage_density":
				var _d = 1.0
				if _value == "medium": _d = 0.7
				elif _value == "low": _d = 0.3
				for _n in $Decoration/Foliage.get_children():
					if _n is FoliageSpawner: _n.set_density(_d)
			"volume": Utilities.set_master_vol()
			"music_vol": $Music.volume_db = linear_to_db(
				clamp(float(_value) * 0.55, 0.0, 1.0))
			"bloom":
				if _value == "on":
					$Sky.environment.glow_enabled = true
				elif _value == "off":
					$Sky.environment.glow_enabled = false
	)
	SettingsHandler.refresh(["volume", "window_mode"])
	
	Global.cursor_enabled.connect(func(data):
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
	
	# Fade volume in and play music after a short delay
	await get_tree().create_timer(0.5).timeout
	var vol_tween = create_tween()
	vol_tween.tween_method(Utilities.set_master_vol, 0.0, Utilities.get_user_vol(), 1.0)
	await get_tree().create_timer(4.0).timeout
	$Music.play()
