extends Node
# SettingsHandler
# Handles the management and updating of settings
const FILE_PATH = "user://save/settings.dat"
const MIN_FOV = 55
const MAX_FOV = 90
const DEFAULT_SETTINGS = { 
	"music_vol": 0.85, # ratio (1.0),
	"volume": 1.0,
	"window_mode": "exclusive_full_screen",
	"foliage_density": "high",
	"bloom": "on",
	"orbit_sensitivity": 0.5,
	"labels": "hide",
	"action_camera": "off_by_default",
	"fps_cap": 60,
	"vsync": "on",
	"fov": 0.63,
	"aa": "msaa_(4x)",
	"saturation": 0.32
}
@onready var settings = DEFAULT_SETTINGS.duplicate()
signal setting_changed(parameter)

func get_fov_deg() -> int:
	return(MIN_FOV + settings.fov * (MAX_FOV - MIN_FOV))

func load_from_file() -> void:
	if FileAccess.file_exists(FILE_PATH):
		var file = FileAccess.open(FILE_PATH, FileAccess.READ)
		var _file_settings = file.get_var()
		# Update from a full template rather than replacing it - means that if
		# another setting is added, an old config file without it won't
		# overwrite it
		for f in _file_settings:
			if f in settings:
				settings[f] = _file_settings[f]
		file.close()
	else:
		save_to_file()

func save_to_file() -> void:
	if !DirAccess.dir_exists_absolute("user://save"):
		DirAccess.make_dir_absolute("user://save")
	
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_var(settings)
	file.close()

func reset() -> void:
	settings = DEFAULT_SETTINGS.duplicate()
	refresh()
	save_to_file()

# Ping 'setting_changed' for all settings except those included in the
# exceptions list
func refresh(exceptions: Array[String] = []) -> void:
	for s in settings:
		if !s in exceptions:
			setting_changed.emit(s)

func update(parameter, value) -> void:
	settings[parameter] = value
	setting_changed.emit(parameter)

func _ready() -> void:
	load_from_file()
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/printsettings":
			print(settings))
