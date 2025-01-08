class_name SaveHandler extends Node
# Save - handles saving and loading all player information EXCEPT
# settings and decorations

signal story_advanced

const OBJECTIVE_WEED_COUNT = 3
var first_run = true

const STORY_POINTS = [
	"game_start",
	"pick_weeds",
	"clear_bugs"
]

var STORY_POINT_SCRIPT = {
	"game_start": {
		"title": "1. A Helping Hand",
		"description": "Nayos was not easy on the Commander and I; the force of a Kryptis turret's blast left my plating cracked and my servos crushed and fragmented. Repair and recovery is a slow process and, as grateful as I am for my jade tech\u00ADnicians, it pains me to be away from the Commander for so long. Though perhaps, as I rehabilitate, I too can help build something meaningful.\n[font_size=9] [/font_size]\n[color=white]Talk to Pulley-4 about tending the garden![/color]",
		"sticker": load('res://generic/textures/stickers/sticker_warning.png'),
		"objective": "talk to Pulley-4 about tending the garden."
	},
	"pick_weeds": {
		"objective": "pick " + str(OBJECTIVE_WEED_COUNT) + " weeds and deposit them at the compost bin."
	},
	"clear_bugs": {
		"title": "((Bug-clearing))",
		"description": "((Bug-clearing))",
		"objective": "use ((Resonance Charges)) from the cleaning station to disperse the pests spoiling the garden."
	}
}

const FILE_PATH = "user://save/save.dat"
const DEFAULT_DATA = {
	"story_point": "game_start",
	"crumbs": [],
	"crumb_count": {},
	"weeds": 0, # weeds in inventory
	"deposited_weeds": 0
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
		first_run = false
		var file = FileAccess.open(FILE_PATH, FileAccess.READ)
		data = file.get_var()
		#for f in _file_save:
			#if f in data: data[f] = _file_save[f]
		file.close()
	else: reset()

func reset() -> void:
	data = DEFAULT_DATA.duplicate(true)
	Global.current_effects = []
	save_to_file()

func save_to_file() -> void:
	for _fx in Global.current_effects:
		if _fx.contains("weed"):
			Save.data.weeds = int(_fx.split("=")[1])
	
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func _ready() -> void:
	if FileAccess.file_exists(FILE_PATH):
		first_run = false
	Global.save_handler = self # reference
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/savedata":
			save_to_file()
		elif _cmd == "/printsavedata":
			print(Save.data))
	
	Global.crumbs_updated.connect(func():
		if (Save.data.story_point == "pick_weeds"
			and Save.data.deposited_weeds >= OBJECTIVE_WEED_COUNT):
			advance_story()
			Global.summon_story_panel.emit(STORY_POINT_SCRIPT["clear_bugs"]))
	
	# Don't load until we get to the map...?
	#load_from_file()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_to_file()
		get_tree().quit() # default behavior
