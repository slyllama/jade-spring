extends Node3D

func _ready() -> void:
	SettingsHandler.setting_changed.connect(func(parameter):
		var _value = SettingsHandler.settings[parameter]
		match parameter:
			"window_mode":
				if _value == "full_screen": get_window().mode = Window.MODE_FULLSCREEN
				elif _value == "maximized": get_window().mode = Window.MODE_MAXIMIZED
				else: get_window().mode = Window.MODE_WINDOWED
			"foliage_density":
				var _d = 1.0
				if _value == "medium":
					_d = 0.7
				elif _value == "low":
					_d = 0.3
				for _n in $Foliage.get_children():
					if _n is FoliageSpawner:
						_n.set_density(_d)
			"grass_aa":
				for _n in $Foliage.get_children():
					if _n is FoliageSpawner:
						if _value == "on":
							_n.set_aa(true)
						else:
							_n.set_aa(false)
	)
	
	SettingsHandler.refresh()
