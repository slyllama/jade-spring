extends Node
# Save - handles saving and loading all player information EXCEPT
# settings and decorations

const FILE_PATH = "user://save.dat"

const DEFAULT_DATA = []
var data = []

func load_from_file() -> void:
	if FileAccess.file_exists(FILE_PATH):
		var file = FileAccess.open(FILE_PATH, FileAccess.READ)
		var _file_save = file.get_var()
		# Update from a full template rather than replacing it - means that if
		# another setting is added, an old config file without it won't
		# overwrite it
		for f in _file_save:
			if f in data:
				data[f] = _file_save[f]
		file.close()
	else:
		save_to_file()

func reset() -> void:
	data = DEFAULT_DATA.duplicate()
	save_to_file()

func save_to_file() -> void:
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func _ready() -> void:
	data = DEFAULT_DATA.duplicate()
	save_to_file()
