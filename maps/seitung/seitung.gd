extends Node3D

func _ready() -> void:
	SettingsHandler.setting_changed.connect(func(parameter):
		var _value = SettingsHandler.settings[parameter]
		match parameter:
			"window_mode":
				if _value == "full_screen": get_window().mode = Window.MODE_FULLSCREEN
				elif _value == "maximized": get_window().mode = Window.MODE_MAXIMIZED
				else: get_window().mode = Window.MODE_WINDOWED
	)
	
	SettingsHandler.refresh()
	#for _n in $Foliage.get_children():
		#if _n is FoliageSpawner:
			#_n.set_density(0.5)
