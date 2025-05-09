extends Node
# SteamHandler
# Handle all Steam connections and functions

const APP_ID = 3561310

@onready var user_id = Steam.get_current_steam_id()
@export var show_debug = true
var steam_loaded = false
signal stats_refreshed

const AchievementsList = [
	"story_completion",
	"game_completion",
	"homesteader",
	"architect",
	"my_friend_ratchet",
	"twilight_peace"
]

const StatsList = [
	"karma_earned",
	"weeds_picked",
	"bugs_cleared",
	"void_dispelled",
	"decos_placed"
]

const Achievements = {
	"story_completion": {
		"title": "A Good Day's Work",
		"desc": "Complete all of Ratchet's garden-clearing objectives.",
		"icon_unearned": preload("res://lib/steam/achievements/icons/story_completion.jpg"),
		"icon_earned": preload("res://lib/steam/achievements/icons/story_completion_earned.jpg")
	},
	"game_completion": {
		"title": "Spring Clean",
		"desc": "Clear the garden of all weeds, pests, and Dragonvoid.",
		"icon_unearned": preload("res://lib/steam/achievements/icons/game_completion.jpg"),
		"icon_earned": preload("res://lib/steam/achievements/icons/game_completion_earned.jpg")
	},
	"twilight_peace": {
		"title": "Twilight's Peace",
		"desc": "Make night fall over the Jade Spring.",
		"icon_unearned": preload("res://lib/steam/achievements/icons/twilight_peace.jpg"),
		"icon_earned": preload("res://lib/steam/achievements/icons/twilight_peace_earned.jpg")
	},
	"my_friend_ratchet": {
		"title": "My Friend Ratchet",
		"desc": "Hear everything Ratchet has to say.",
		"icon_unearned": preload("res://lib/steam/achievements/icons/ratchet.jpg"),
		"icon_earned": preload("res://lib/steam/achievements/icons/ratchet_earned.jpg")
	},
	"homesteader": {
		"title": "Homesteader",
		"desc": "Place 25 decorations.",
		"icon_unearned": preload("res://lib/steam/achievements/icons/homesteader.jpg"),
		"icon_earned": preload("res://lib/steam/achievements/icons/homesteader_earned.jpg")
	},
	"architect": {
		"title": "Architect",
		"desc": "Place 50 decorations.",
		"icon_unearned": preload("res://lib/steam/achievements/icons/architect.jpg"),
		"icon_earned": preload("res://lib/steam/achievements/icons/architect_earned.jpg")
	}
}

var stats = {
	"karma_earned" = 0,
	"weeds_picked" = 0,
	"bugs_cleared" = 0,
	"void_dispelled" = 0,
	"decos_placed" = 0
}

func printd(debug_str: String) -> void:
	if show_debug:
		print("[Steam] " + debug_str)

func get_achievment_completion(achievement: String) -> int:
	if !steam_loaded: return(-1)
	if Steam.getAchievement(achievement).achieved: return(1)
	else: return(0)

func get_stat(stat: String) -> int:
	if !steam_loaded: return(-1)
	return(Steam.getStatInt(stat))

func add_to_stat(stat: String, amount = 1) -> void:
	if !steam_loaded:
		printd("Couldn't add to stat '" + stat + "'.")
		return
	Steam.setStatInt(stat, Steam.getStatInt(stat) + amount)

func complete_achievement(achievement: String) -> void:
	if !steam_loaded: return
	Steam.setAchievement(achievement)
	Steam.storeStats()

func store_stats() -> void:
	if !steam_loaded: return
	Steam.storeStats()

func refresh_stats() -> void:
	if !steam_loaded: return
	Steam.requestUserStats(Steam.get_current_steam_id())

func _on_steam_stats_ready(game: int, result: int, _user: int) -> void:
	printd("Stats callback (" + str(game) + " -> " + str(result) + ")")
	
	if result == Steam.RESULT_OK and game == APP_ID:
		for _s in stats:
			stats[_s] = Steam.getStatInt(_s)
		stats_refreshed.emit()
		printd("Stats callback success!")
	else: printd("Stats callback error.")

func _init() -> void:
	var init_steam: Dictionary = Steam.steamInitEx(true, APP_ID)
	if init_steam.status == Steam.STEAM_API_INIT_RESULT_OK:
		steam_loaded = true
	printd("Validating... " + str(init_steam))

func _ready() -> void:
	await get_tree().process_frame
	if !steam_loaded:
		return
	Steam.current_stats_received.connect(_on_steam_stats_ready)
	Steam.user_stats_received.connect(_on_steam_stats_ready)
	Steam.requestUserStats(Steam.get_current_steam_id())
	
	Steam.overlay_toggled.connect(func(active, _user_initiated, _app_id):
		printd("Overlay toggled (" + str(active) + ")")
		if active: # pause the game
			for _i in 3: await get_tree().process_frame
			if Global.debug_allowed:
				Global.announcement_sent.emit("((Steam Overlay enabled))")
			Global.action_cam_disable.emit()
			get_tree().paused = true
		else:
			if Global.debug_allowed:
				Global.announcement_sent.emit("((Steam Overlay disabled))")
			for _i in 3: await get_tree().process_frame
			get_tree().paused = false)
	
	Global.command_sent.connect(func(cmd):
		if steam_loaded:
			## Stats commands
			if cmd == "/pause":
				for _i in 3: await get_tree().process_frame
				Global.action_cam_disable.emit()
				get_tree().paused = true
			if cmd == "/unpause":
				get_tree().paused = false
			if cmd == "/clearstats":
				Steam.resetAllStats(true)
				await get_tree().process_frame
				get_tree().quit()
	)
