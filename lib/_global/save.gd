class_name SaveHandler extends Node
# Save - handles saving and loading all player information EXCEPT
# settings and decorations

signal story_advanced
signal karma_changed

const OBJECTIVE_WEED_COUNT = 3
const OBJECTIVE_PEST_COUNT = 2
var first_run = true

const STORY_POINTS = [
	"game_start",
	"pick_weeds",
	"clear_bugs",
	"ratchet_dv"
]

var STORY_POINT_SCRIPT = {
	"game_start": {
		"title": "1. A Helping Hand",
		"description": "Nayos was tough on the Commander and I; a Kryptis turret-blast left my Jade Bot plating cracked and my servos badly damaged. Repair and recovery is a slow process and, as grateful as I am for my jade tech\u00ADnicians, it pains me to be away from the Commander for so long! Though perhaps, as I rehabilitate here, I too can help build some\u00ADthing meaningful. <Talk to Ratchet about tending to the garden!>",
		"sticker": load('res://generic/textures/stickers/sticker_warning.png'),
		"objective": "Talk to the steward golem Ratchet about tending to the garden."
	},
	"pick_weeds": {
		"title": "1. A Helping Hand",
		"objective": "Pick weeds and drop them into the compost bin. Collect any hard-earned Karma that drops!"
	},
	"clear_bugs": {
		"title": "2. Pesky Pests",
		"description": "Bugs and pests are Ratchet's great nemeses, but I have some tricks up my sleeve to deal with them. In the shed are coils of Raw Dispersion Flux supplied from Rata Sum; by activating them near bug swarms, I can disturb the air currents and safely clear them out! <Collect Raw Dispersion Flux from Ratchet's shed and use it to scatter pest clouds. Once the carrier golems are following you, interact with a pest cloud and follow the node that appears with your slider to disperse the Flux and clear out the bugs.>",
		"objective": "Use Raw Dispersion Flux from Ratchet's shed to clear out pests spoiling the garden."
	},
	"ratchet_dv" : {
		"title": "2. Pesky Pests",
		"description": "((Description))",
		"objective": "Speak to Ratchet about their efforts in solving the Dragonvoid problem."
	}
}

const FILE_PATH = "user://save/save.dat"
const DEFAULT_DATA = {
	"story_point": "game_start",
	"crumbs": [],
	"crumb_count": {},
	"weeds": 0, # weeds in inventory
	"deposited_weeds": 0,
	"karma": 0,
	"fishing_tutorial_played": false,
	"unlocked_decorations": []
}
var data = {}

func has_sufficient_karma(amount: int) -> bool:
	if data.karma - amount >= 0: return(true)
	else: return(false)

func add_karma(amount: int) -> void:
	if amount > 0:
		data.karma += amount
		save_to_file()
		karma_changed.emit()

func subtract_karma(amount: int) -> void:
	if amount > 0:
		data.karma -= amount
		save_to_file()
		karma_changed.emit()

func is_save_valid() -> bool:
	if FileAccess.file_exists(FILE_PATH):
		var _f = FileAccess.open(FILE_PATH, FileAccess.READ)
		data = _f.get_var()
		_f.close()
		for _key in DEFAULT_DATA:
			if !_key in data:
				return(false)
	else:
		return(false)
	return(true)

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
	
	if data == {}:
		breakpoint # TODO: trying to catch when a blank save file situation happens
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
			print(Save.data)
		elif "/addkarma=" in _cmd:
			var _k = int(_cmd.replace("/addkarma=", ""))
			add_karma(_k))
	
	Global.crumbs_updated.connect(func():
		for _i in 3: await get_tree().process_frame
		if !"story_point" in Save.data:
			print("[WARNING] no save data loaded (even empty).")
			return
		
		if (Save.data.story_point == "pick_weeds"
			and Save.data.deposited_weeds >= OBJECTIVE_WEED_COUNT):
			advance_story()
			Global.summon_story_panel.emit(STORY_POINT_SCRIPT["clear_bugs"])
		elif (Save.data.story_point == "clear_bugs"
			and Global.crumb_handler.totals.bug - Save.data.crumb_count.bug >= OBJECTIVE_PEST_COUNT):
			advance_story()
			Global.summon_story_panel.emit(STORY_POINT_SCRIPT["ratchet_dv"])
	)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if Save.data != {}: # only save if there is something to save
			save_to_file()
		get_tree().quit() # default behavior
