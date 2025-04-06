extends Node
# SteamHandler
# Handle all Steam connections and functions

const APP_ID = 3561310

@onready var user_id = Steam.get_current_steam_id()
@export var show_debug = true
var steam_loaded = false
signal stats_refreshed

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

func add_to_stat(stat: String, amount = 1) -> void:
	if !steam_loaded:
		printd("Couldn't add to stat '" + stat + "'.")
		return
	Steam.setStatInt(stat, Steam.getStatInt(stat) + amount)

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
	
	#Global.command_sent.connect(func(cmd):
		#if stats_loaded:
			## Stats commands
			#if cmd == "/printteststat":
				#printd("karma_earned: " + str(Steam.getStatInt("karma_earned")))
			#elif cmd == "/incrementteststat":
				#Steam.setStatInt("karma_earned", Steam.getStatInt("karma_earned") + 1)
				#Global.command_sent.emit("/printteststat")
			#elif cmd == "/printtestachieve":
				#printd(str(Steam.getAchievement("story_completion")))
		#else:
			#printd("Stats weren't successfully loaded.")
	#)
