class_name SaveHandler extends Node
# Save - handles saving and loading all player information EXCEPT
# settings and decorations

signal story_advanced
signal karma_changed

const OBJECTIVE_WEED_COUNT = 5
const OBJECTIVE_PEST_COUNT = 3
const OBJECTIVE_DV_COUNT = 1
const GIFT_STORY_POINT = "stewardship" # gift will unlock past this point - debugging
var first_run = true

const RATCHET_SECONDARY_DIALOGUE = [
	"pick_weeds_alt",
	"clear_bugs_alt",
	"no_dv_charge",
	"dv_charge",
	"raiqqo",
	"gift"
]

const STORY_POINTS = [
	"game_start",
	"pick_weeds",
	"clear_bugs",
	"ratchet_dv",
	"clear_dv",
	"charged_dv", # used for checking alternate dialogue in story
	"ratchet_gratitude",
	"gratitude",
	"stewardship",
	"debug"
]

var STORY_POINT_SCRIPT = {
	"game_start": {
		"title": "1. A Helping Hand",
		"description": "Nayos was tough on the Commander and I; a Kryptis turret-blast left my Jade Bot plating cracked and my servos badly damaged. When I first came back online I had little clue as to where I was, but I have since learned that this place is the Jade Spring, a secluded garden overseen by a golem named Ratchet. I'd like to show my appreciation for the safe haven that has been provided to me during my rehabilitation. Perhaps while I am here, I too can help build something meaningful. <Talk to Ratchet about tending to the garden!>",
		"objective": "Talk to the steward golem Ratchet about tending to the garden."
	},
	"pick_weeds": {
		"title": "1. A Helping Hand",
		"objective": "Pick weeds and drop them into the compost bin. Collect any hard-earned Karma that drops!"
	},
	"clear_bugs": {
		"title": "2. Pesky Pests",
		"description": "Bugs and pests are Ratchet's great nemeses, but I have some tricks up my sleeve. In the shed are coils of Raw Dispersion Flux supplied from Rata Sum; by activating them near bug swarms, I can disturb the air currents and safely clear them out! <Collect Raw Dispersion Flux from Ratchet's shed and use it to scatter pest clouds. Once the carrier golems are following you, interact with a pest cloud to disperse the Flux and clear out the bugs.>",
		"objective": "Use Raw Dispersion Flux from Ratchet's shed to clear out pests."
	},
	"ratchet_dv": {
		"title": "3. Banishing the Void",
		"description": "My communicator is buzzing; it's a message from Ratchet. 'I believe that I've established a solution for the Dragonvoid incursion blocking all our devices and systems. Please come and visit me at your earliest convenience so that we can clear out these blights once and for all.' <Speak to Ratchet about their efforts in solving the Dragonvoid problem.>",
		"objective": "Speak to Ratchet about their efforts in solving the Dragonvoid problem."
	},
	"clear_dv": {
		"title": "3. Banishing the Void",
		"objective": "Attune a coil of Raw Dispersion Flux using Ratchet’s Makeshift Attunement Gadget. Use it to dispel a column of Dragonvoid."
	},
	"charged_dv": {
		"title": "3. Banishing the Void",
		"objective": "Attune a coil of Raw Dispersion Flux using Ratchet’s Makeshift Attunement Gadget. Use it to dispel a column of Dragonvoid."
	},
	"ratchet_gratitude": {
		"title": "4. Ratchet's Gratitude",
		"description": "As the dragon's tesseract collapses into static, my communicator starts to buzz again. 'Excelsior! Marvelous! Systems rebooting... engaged and operational. We'll be able to clear out the rest of this Void as we go.' <All decoration tools are now available to you! You can place and delete items, move, scale, rotate, and duplicate them. You can unlock special decorations with Karma earned from helping clear the garden. Oh - and it looks like Ratchet has something they want to discuss with you!>",
		"objective": "With the Dragonvoid problem well on its way to being solved, Ratchet has something to speak to you about."
	},
	"gratitude": {
		"title": "4. Ratchet's Gratitude",
		"objective": "The garden air is clearer than ever, and the Jade Spring is well on its way to being fully cleansed."
	},
	"stewardship": {
		"title": "5. Stewardship",
		"description": "Thanks to your efforts (and Ratchet's diligent supervision), the mists of the Jade Spring now rest in wholeness and health. Raiqqo is away on his travels, but has left a small token of his appreciation with Ratchet.",
		"objective": "((Stewardship.))"
	},
	"debug": {
		"title": "((Debug Map))",
		"objective": "Map for testing."
	}
}

const FILE_PATH = "user://save/save.dat"
const DEFAULT_DATA = {
	"v1.0b": true,
	"story_point": "game_start",
	"crumbs": [],
	"crumb_count": {},
	"weeds": 0,
	"deposited_weeds": 0,
	"karma": 0,
	"fishing_tutorial_played": false,
	"unlocked_decorations": [],
	"hints_played": [],
	"dialogue_played": [] # only dialogue with an 'ID' field is added here
}
var data = DEFAULT_DATA.duplicate(true)

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

func has_dv_charge() -> bool:
	var _has = false
	for _fx in Global.current_effects:
		if "d_" in _fx:
			_has = true
	return(_has)

# Is the player at or after this story point?
func is_at_story_point(story_point: String) -> bool:
	var _check_idx = STORY_POINTS.find(story_point)
	var _save_idx = STORY_POINTS.find(data.story_point)
	if _save_idx >= _check_idx: return(true)
	else: return(false)

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
		
		# Discord updating
		if DiscordRPC.get_is_discord_working():
			DiscordRPC.details = STORY_POINT_SCRIPT[data.story_point].title
			DiscordRPC.refresh()

func load_from_file() -> void:
	if Global.map_name == "debug":
		data = DEFAULT_DATA.duplicate(true)
		return
	if FileAccess.file_exists(FILE_PATH):
		first_run = false
		var file = FileAccess.open(FILE_PATH, FileAccess.READ)
		data = file.get_var()
		file.close()
		
		# Discord updating
		if DiscordRPC.get_is_discord_working():
			DiscordRPC.details = STORY_POINT_SCRIPT[data.story_point].title
			DiscordRPC.refresh()
	else: reset()

func reset() -> void:
	data = DEFAULT_DATA.duplicate(true)
	Global.current_effects = []
	save_to_file()

func save_to_file() -> void:
	if Global.map_name == "debug":
		#print("[Save] debug map; not saving.")
		return
	for _fx in Global.current_effects:
		if _fx.contains("weed"):
			Save.data.weeds = int(_fx.split("=")[1])
	
	if data == {}:
		breakpoint # TODO: trying to catch when a blank save file situation happens
	
	if !DirAccess.dir_exists_absolute("user://save"):
		DirAccess.make_dir_absolute("user://save")
	
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
			add_karma(_k)
		elif _cmd == "/advancestory":
			advance_story()
			Global.crumbs_updated.emit()
		elif "/ifstory=" in _cmd:
			var story_point = _cmd.replace("/ifstory=", "")
			is_at_story_point(story_point)
		)
	
	Global.crumbs_updated.connect(func():
		for _i in 3: await get_tree().process_frame
		if !"story_point" in Save.data:
			print("[WARNING] no save data loaded (even empty).")
			return
		
		if (Save.data.story_point == "pick_weeds"
			and Save.data.deposited_weeds >= OBJECTIVE_WEED_COUNT):
			advance_story()
			
			await get_tree().create_timer(0.5).timeout # delay before the story panel opens
			Global.summon_story_panel.emit(STORY_POINT_SCRIPT["clear_bugs"])
		elif (Save.data.story_point == "clear_bugs"
			and Global.crumb_handler.totals.bug - Save.data.crumb_count.bug >= OBJECTIVE_PEST_COUNT):
			advance_story()
			
			await get_tree().create_timer(0.5).timeout # delay before the story panel opens
			Global.summon_story_panel.emit(STORY_POINT_SCRIPT["ratchet_dv"])
		elif Save.data.story_point == "clear_dv" or Save.data.story_point == "charged_dv":
			if Global.crumb_handler.totals.dragonvoid - Save.data.crumb_count.dragonvoid >= OBJECTIVE_DV_COUNT:
				if Save.data.story_point == "clear_dv": Save.data.story_point = "charged_dv"
				advance_story()
			
				# ACHIEVEMENT - STORY COMPLETION
				if SteamHandler.get_achievment_completion("story_completion") < 1:
					print("[Save] Qualifies for story completion achievement.")
					if Save.is_at_story_point("ratchet_gratitude"):
						SteamHandler.complete_achievement("story_completion")
						print("[Save] Story completion achievement earned!")
				
				await get_tree().create_timer(0.5).timeout # delay before the story panel opens
				Global.summon_story_panel.emit(STORY_POINT_SCRIPT["ratchet_gratitude"])
	)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.design_handler.create_design_slot()
		if DiscordRPC.get_is_discord_working():
			DiscordRPC.refresh()
		
		if Save.data != {}: # only save if there is something to save
			Save.data.karma += Global.assigned_karma
			save_to_file()
			
			SteamHandler.store_stats()
			await get_tree().process_frame
		get_tree().quit() # default behavior
