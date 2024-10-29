extends CanvasLayer

func _ready():
	SettingsHandler.setting_changed.connect(func(parameter):
		var _value = SettingsHandler.settings[parameter]
		match parameter:
			"window_mode":
				if _value == "full_screen": get_window().mode = Window.MODE_FULLSCREEN
				elif _value == "maximized": get_window().mode = Window.MODE_MAXIMIZED
				else: get_window().mode = Window.MODE_WINDOWED
	)
	SettingsHandler.refresh(["volume"])
	
	$Buttons/Play.grab_focus()
	var _splash_fade = create_tween()
	_splash_fade.tween_property($Splash, "modulate:a", 0.0, 0.35)
	await _splash_fade.finished
	
	$Splash.queue_free()

func _on_play_button_down() -> void:
	get_tree().change_scene_to_file("res://lib/loader/loader.tscn")
