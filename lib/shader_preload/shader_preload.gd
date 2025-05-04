extends Node
# ShaderPreload
# Automates actions to precompile shaders on first run

@export var print_debug_text = true

const Fishing = preload("res://lib/fishing/fishing.tscn")
const Dialogue = preload("res://lib/dialogue/dialogue.tscn")
const Attenuator = preload("res://lib/attenuator/attenuator.tscn")

const PLAYER_POSITIONS = [
	Vector3(-3.7, 2.0, 13.4),
	Vector3(9.3, 2.0, 11.0),
	Vector3(0.0, 2.0, 22.2)
]

func pdebug(text: String) -> void:
	if print_debug_text:
		print("[ShaderPreload] " + text)

func _ready():
	await get_tree().current_scene.ready
	
	var args = Array(OS.get_cmdline_args())
	if args.has("--preloadshaders=false") or Save.data.story_point != "game_start":
		pdebug("Skipping shader preload.")
		Global.shader_preload_complete.emit()
		queue_free()
		return
	
	pdebug("Preloader ready.")
	var _player_og_pos = Global.player.global_position
	
	# Tour the player around the map
	for _p in PLAYER_POSITIONS:
		Global.player.global_position = _p
		pdebug("Moving player to " + str(_p) + ".")
		await get_tree().process_frame
	Global.player.global_position = _player_og_pos
	
	# Load fishing for a frame
	pdebug("Caching fishing.")
	var _f = Fishing.instantiate()
	_f.preload_mode = true
	Global.hud.add_child(_f)
	await get_tree().process_frame
	_f.end(true) # use `true` to end instantly (i.e., no waiting)
	
	# Load dialogue for a frame
	pdebug("Caching dialogue.")
	var _d = Dialogue.instantiate()
	Global.hud.add_child(_d)
	_d.open()
	await get_tree().process_frame
	_d.close(true)
	
	# Load decoration pane for a frame
	pdebug("Caching decoration pane.")
	Global.deco_pane_opened.emit()
	await get_tree().process_frame
	Global.deco_pane_closed.emit()
	
	# Load Attenuator for a frame
	pdebug("Caching Attenuator.")
	var _a = Attenuator.instantiate()
	_a.supress_hint = true
	Global.hud.add_child(_a)
	_a.close()
	
	pdebug("Clearing Disperson Golems.")
	await get_tree().process_frame
	Global.player.clear_dgolems()
	
	await get_tree().process_frame
	Global.shader_preload_complete.emit()
