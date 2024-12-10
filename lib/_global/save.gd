extends Node
# Save - handles saving and loading all player information EXCEPT
# settings and decorations

signal story_advanced

const STORY_POINTS = [
	"game_start",
	"bulwark_gyro"
]

const STORY_POINT_SCRIPT = {
	"game_start": {
		"title": "1. A Helping Hand",
		"description": "Nayos was not easy on us; the force of that Kryptis turret's blast left my plating cracked and my servos crushed and fragmented. Repair and recovery will be a slow process and, as grateful as I am for my jade tech\u00ADnicians, it pains me to be away from the Commander for so long. Though perhaps, as I rehabilitate, I too can help build something meaningful.\n[font_size=9] [/font_size]\n[color=white]Talk to Pulley-4 about tending the garden![/color]",
		"objective": "Talk to Pulley-4 about tending the garden."
	},
	"bulwark_gyro": {
		"objective": "Pick 10 weeds and deposit them at the compost bin."
	}
}

const FILE_PATH = "user://save.dat"
const DEFAULT_DATA = {
	"story_point": "game_start",
	"weeds": 0 # weeds in inventory
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
	for _fx in Global.current_effects:
		if _fx.contains("weed"):
			Save.data.weeds = int(_fx.split("=")[1])
	
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_action"):
		advance_story()

func _ready() -> void:
	load_from_file()
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/savedata":
			save_to_file())

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_to_file()
		get_tree().quit() # default behavior
