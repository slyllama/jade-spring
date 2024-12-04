extends Node
# Save - handles saving and loading all player information EXCEPT
# settings and decorations

signal story_advanced

const STORY_POINTS = [
	"game_start",
	"bulwark_gyro"
]

const FILE_PATH = "user://save.dat"
const DEFAULT_DATA = {
	"story_point": "game_start"
}
var data = {}

# Advance the story by looking up STORY_POINTS (as long as you're not at the last one)
func advance_story() -> void:
	var _ind = STORY_POINTS.find(data.story_point)
	if _ind+1 < STORY_POINTS.size():
		data.story_point = STORY_POINTS[_ind+1]
		story_advanced.emit()
		save_to_file()

func load_from_file() -> void:
	if FileAccess.file_exists(FILE_PATH):
		var file = FileAccess.open(FILE_PATH, FileAccess.READ)
		data = file.get_var()
		#for f in _file_save:
			#if f in data: data[f] = _file_save[f]
		file.close()
	else: reset()

func reset() -> void:
	data = DEFAULT_DATA.duplicate()
	save_to_file()

func save_to_file() -> void:
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_action"):
		advance_story()

func _ready() -> void:
	load_from_file()
