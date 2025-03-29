extends Node
# SteamHandler
# Handle all Steam connections and functions

const APP_ID = 3561310
@onready var user_id = Steam.get_current_steam_id()

@export var show_debug = true

func printd(debug_str: String) -> void:
	if show_debug:
		print("[Steam] " + debug_str)

func _on_steam_stats_ready(game: int, result: int, _user: int) -> void:
	printd("Stats callback (" + str(game) + " -> " + str(result) + ")")
	
	if result == Steam.RESULT_OK and game == APP_ID: printd("Stats callback success!")
	else: printd("Stats callback error.")

func _init() -> void:
	var init_steam: Dictionary = Steam.steamInitEx(true, APP_ID)
	printd("Validating... " + str(init_steam))

func _ready() -> void:
	Steam.current_stats_received.connect(_on_steam_stats_ready)
	Steam.user_stats_received.connect(_on_steam_stats_ready)
	
	await get_tree().process_frame
	Steam.requestUserStats(Steam.get_current_steam_id())
