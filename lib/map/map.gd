extends Node3D
# Map
# Base class for map functionalirt

const FishingInstance = preload("res://lib/fishing/fishing.tscn")
const Karma = preload("res://lib/karma/karma.tscn")

var picking_disabled_objects: Array[StaticBody3D] = []
var rng = RandomNumberGenerator.new()

# Re-enable mouse event-disabled static bodies
func reset_picking_disabled_objects() -> void:
	for _n in picking_disabled_objects:
		_n.input_ray_pickable = true
	picking_disabled_objects = []

func spawn_karma(amount: int, orb_position: Vector3, radius = 1.0) -> void:
	for _i in amount:
		var _a = deg_to_rad(360.0 / amount * _i + rng.randf() * 45.0)
		var _offset = Vector3(radius * cos(_a), 0, radius * sin(_a))
		
		var _k = Karma.instantiate()
		add_child(_k)
		_k.global_position = orb_position + _offset
		_k.global_position.y = 2.0
		await get_tree().create_timer(0.025).timeout

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_debug"):
		Global.debug_enabled = !Global.debug_enabled
		Global.debug_toggled.emit()

func set_marker_pos() -> void: # set the position of the story marker
	match Save.data.story_point:
		"game_start": $StoryMarker.position = $Pulley.position
		"pick_weeds": $StoryMarker.position = $WeedBin.get_node("Collision").global_position
		"clear_bugs": $StoryMarker.global_position = $Discombobulator/SpatialText.global_position - Vector3(0, 1.9, 0)
		"ratchet_dv": $StoryMarker.position = $Pulley.position
		"clear_dv": $StoryMarker.position = $ChargingStation.position + Vector3(-0.4, 0, 0)
		"free_reign": $StoryMarker.position = Vector3(0, -20, 0)
		"debug": $StoryMarker.position = Vector3(0, -20, 0)
		"_": $StoryMarker.position = Vector3(0, -20, 0) # hide under map

func _ready() -> void:
	# Set initial state
	Global.safe_point = $SafePoint
	Global.debug_toggled.emit()
	Global.deco_pane_open = false # reset
	Global.dialogue_open = false # reset
	Global.spawn_karma.connect(spawn_karma)
	
	Global.command_sent.connect(func(cmd):
		if cmd == "/hidecrumbs":
			for _c in $CrumbHandler.get_children():
				_c.visible = false
				Global.announcement_sent.emit("((Hiding crumbs.))")
		elif cmd == "/showcrumbs":
			for _c in $CrumbHandler.get_children():
				_c.visible = true
				Global.announcement_sent.emit("((Showing crumbs.))")
		elif cmd == "/screenshot":
			$Shutter.play()
			Global.hud.hide_hud()
			for _x in 2: await get_tree().process_frame
			var _image = get_viewport().get_texture().get_image()
			var _time_string = Time.get_datetime_string_from_system(
				).replace(":", "-").replace("T", " ")
			_image.save_png("user://save/Screenshot " + _time_string + ".png")
			Global.hud.show_hud()
		elif cmd == "/gravity":
			if "gravity" in Global.current_effects:
				Global.remove_effect.emit("gravity")
			else:
				Global.add_effect.emit("gravity")
		elif cmd == "/rotatesun":
			$Sky/Sun.global_rotation_degrees.y += 45.0
		elif cmd == "/fish":
			var _f = FishingInstance.instantiate()
			add_child(_f)
		elif cmd == "/cinematic=on":
			Input.action_press("toggle_debug")
			Global.command_sent.emit("/playersmooth=0.3")
			Global.command_sent.emit("/speedratio=0.65")
			Global.command_sent.emit("/orbitsmooth=0.16")
		elif cmd == "/cinematic=off":
			Global.command_sent.emit("/playersmooth=1.0")
			Global.command_sent.emit("/speedratio=1.0")
			Global.command_sent.emit("/orbitsmooth=1.0")
		elif "/spawnkarma=" in cmd:
			var _count = int(cmd.replace("/spawnkarma=", ""))
			_count = clamp(_count, 0, 25)
			spawn_karma(_count, Global.player_position)
		)
	
	Save.story_advanced.connect(set_marker_pos)
	await get_tree().process_frame
	set_marker_pos()
	
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
		if "gravity" in Global.current_effects:
			Global.remove_effect.emit("gravity")
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
	Utilities.set_master_vol(0.0)
	await get_tree().create_timer(0.5).timeout
	var vol_tween = create_tween()
	vol_tween.tween_method(
		Utilities.set_master_vol, 0.0, Utilities.get_user_vol(), 1.0)
	await get_tree().create_timer(4.0).timeout
