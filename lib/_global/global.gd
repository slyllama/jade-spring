extends Node

var start_params = { "new_save" = false }
var debug_allowed = false

const SPAWN_RADIUS = 2.0 # protect area around spawn point
var rng = RandomNumberGenerator.new()

var camera: Camera3D # reference for ray projections
var crumb_handler: CrumbHandler
var save_handler: SaveHandler
var deco_handler: DecoHandler
var design_handler: DesignHandler
var hud: HUDScript
var player: CharacterBody3D
var orbit_handler: OrbitHandler

# Karma values
var kv_weed = 5
var kv_bug = 10
var kv_dragonvoid = 15
var kv_fish_min = 10
var kv_fish_max = 20

# Karma is added here when spawned, then subtracted when collected. The remainder is added to the player's Karma count
var assigned_karma = 0

var aggressive_culling = false
var aggressive_cull_distance_squared = 100.0

var attenuator_open = false
var bindings_saved_initial = false # make sure this is only done once during game run-time
var bindings_pane_open = false
var camera_basis: Basis
var camera_orbiting = false
var camera_pivot_rotation_degrees = Vector3.ZERO
var camera_position = Vector3.ZERO
var can_move = true
var current_crumb = null
var current_gadget = null
var debug_enabled = false
var deco_button_pressed = false # this will become true on mouse down - decoration placement will not happen until it has been cleared
var deco_pane_open = false
var default_input_map = { }
var design_pane_open = false
var dialogue_open = false
var dragging = false # just reports whether the player is dragging gizmos at the moment or not
var current_effects = [ ]
var foliage_count = 0
var in_exclusive_ui = false
var in_first_person = false
var interact_hint = "Interact"
var last_command = ""
var load_debug_next = false # the next map loaded by the loader will be the debug map if this is true
var override_lock_tools = false
var map_name = ""
var map_entered_once = false
var miniature = false
var mouse_3d_position = Utilities.BIGVEC3
var mouse_3d_override_rotation = null
var mouse_3d_x_rotation = 0.0
var mouse_3d_y_rotation = 0.0
var mouse_3d_scale = Vector3(1, 1, 1)
var mouse_in_ui = false
var mouse_in_deco_pane = false
var orbit_sensitivity_multiplier = 1.0
var player_position = Vector3.ZERO
var player_y_rotation = 0.0
var popup_open = false
var retina_scale = 1.0
var safe_point: Marker3D
var settings_open = false
var snapping = false # don't snap by default
var story_panel_open = false
var target_music_ratio = 1.0
var time_of_day = "day"

signal action_cam_enable # procs action cam
signal action_cam_disable # procs action cam

signal announcement_sent(get_text)
signal attenuator_closed
signal bindings_updated
signal bug_crumb_entered
signal bug_crumb_left
signal check_freshness # force Ratchet to check their story freshness
signal click_sound
signal crumbs_updated
signal command_sent(string)
signal controller_skill(node)
signal debug_toggled
signal debug_skill_used
signal deco_card_clicked(id)
signal decorations_loaded
signal dialogue_opened
signal dialogue_closed
signal dragonvoid_crumb_entered
signal dragonvoid_crumb_left
signal effects_reset # on map change
signal first_person_entered
signal first_person_left
signal fishing_started
signal fishing_canceled
signal flowers_show # flowers screen effect
signal flowers_hide # flowers screen effect
signal generic_area_entered
signal generic_area_left
signal gravity_entered
signal gravity_exited
signal hearts_emit # shortcut - emit from anywhere to spawn hearts
signal jade_bot_sound
signal karma_collected
signal move_player(new_position: Vector3) # function - moves the player
signal override_track_play(get_stream: AudioStreamOggVorbis) # see Jukebox
signal add_effect(id) # more of a function signal - a shortcut to FXList
signal remove_effect(id)
signal ripple
signal settings_pane_opened
signal shader_preload_complete
signal skill_button_down(id: String)
signal skill_button_up(id: String)
signal spawn_karma(amount: int, location: Vector3)
signal vault_entered
signal vault_left
signal weed_crumb_entered
signal weed_crumb_left
signal summon_story_panel(data: Dictionary)
signal close_story_panel

func add_qty_effect(id: String, amount = 1) -> void:
	var _new_amount = amount
	for _fx in current_effects:
		if "=" in _fx: # if is a quantitative effect
			if _fx.split("=")[0] == id:
				_new_amount += int(_fx.split("=")[1])
				remove_effect.emit(_fx)
				#current_effects.erase(_fx)
	add_effect.emit(id + "=" + str(_new_amount))

# Return the quantity of an effect (if it has one, or zero if it doesn't)
func get_effect_qty(effect: String) -> int:
	var _qty = 0
	var _d = effect.split("=") # effect data
	for _fx in Global.current_effects:
		if _d[0] in _fx:
			if "=" in _fx:
				_qty = int(_fx.split("=")[1])
			else: return(-1) # not actually a quantity - return an error
	return(_qty)

func get_dv_quantity() -> int:
	var _i = 0
	for _f in current_effects:
		if "d_" in _f:
			_i += 1
	return(_i)

##### Decoration signals and parameters
const DecoTags = [ "None", "Architecture", "Foliage", "Cantha", "Asura", "Kryta", "Kodan" ]
var DecoData = {}
# [
#	{
#		"node": Decoration,
#		"last_position": Vector3
# ]
var deco_selection_array = []

enum {
	TOOL_MODE_NONE,
	TOOL_MODE_EYEDROPPER,
	TOOL_MODE_ADJUST,
	TOOL_MODE_SELECT,
	TOOL_MODE_SELECT_MULTIPLE,
	TOOL_MODE_DELETE,
	TOOL_MODE_PLACE,
	TOOL_MODE_FISH }
enum {
	TRANSFORM_MODE_OBJECT,
	TRANSFORM_MODE_WORLD }
enum {
	ADJUSTMENT_MODE_TRANSLATE,
	ADJUSTMENT_MODE_ROTATE }

const tool_identities = [ # associations for debug printing
	"TOOL_MODE_NONE",
	"TOOL_MODE_EYEDROPPER",
	"TOOL_MODE_ADJUST",
	"TOOL_MODE_SELECT",
	"TOOL_MODE_SELECT_MULTIPLE",
	"TOOL_MODE_DELETE",
	"TOOL_MODE_PLACE",
	"TOOL_MODE_FISH" ]

signal adjustment_applied # transformation applied and adjustment ended
signal adjustment_canceled # transformation discarded and adjustment ended
signal adjustment_started # transformation started
signal adjustment_reset # reset to default orientation and scale
signal adjustment_mode_rotation
signal adjustment_mode_translate

signal selection_started # applies to eyedropper too
signal selection_canceled # applies to eyedropper too

signal deco_count_changed
signal deco_sampled(data) # decoration sampled with the eyedropper tool
signal deco_pane_closed
signal deco_pane_opened
signal deco_placement_started
signal deco_placement_canceled
signal deco_placed(data)
signal deco_deletion_started # mainly for the HUD overlay
signal deco_deletion_canceled
signal deco_deleted
signal deco_load_started
signal deco_load_ended
signal drag_started
signal snapping_enabled
signal snapping_disabled
signal rotate_left_90 # rotate global position to the next nearest 90deg
signal rotate_right_90 # rotate global position to the last nearest 90deg
signal roll_left_90
signal roll_right_90
signal transform_mode_changed(transform_mode)

const SNAP_INCREMENT = 0.25

var decorations = [] # references to decorations will populate here
var deco_count := 0
var highlighted_decoration: Decoration = null
var active_decoration: Decoration = null # decoration currently being adjusted
var queued_decoration = "none" # next decoration that will be placed
var tool_mode = TOOL_MODE_NONE
var transform_mode = TRANSFORM_MODE_OBJECT
var adjustment_mode = ADJUSTMENT_MODE_TRANSLATE

func toggle_transform_mode() -> void:
	if transform_mode == TRANSFORM_MODE_WORLD:
		transform_mode = TRANSFORM_MODE_OBJECT
	else:
		transform_mode = TRANSFORM_MODE_WORLD
	transform_mode_changed.emit(transform_mode)

##### Cursor signals and parameters

var cursor_active = false
signal mouse_3d_click

signal cursor_enabled(data: Dictionary)
signal cursor_disabled
signal cursor_tint_changed(color: Color)

# Set the cursor on or off
func set_cursor(state = true, data = {}) -> void:
	if state:
		if cursor_active: return # don't enable twice
		cursor_enabled.emit(data)
	else:
		if !cursor_active: return # don't disable twice
		cursor_disabled.emit()
	cursor_active = state

func go_to_safe_point() -> void:
	if safe_point:
		move_player.emit(safe_point.global_position)

func cursor_in_safe_point() -> bool:
	var _coord := Vector2(mouse_3d_position.x, mouse_3d_position.z)
	var _safe_point_coord := Vector2(
			safe_point.global_position.x, safe_point.global_position.z)
	if _coord.distance_to(_safe_point_coord) < SPAWN_RADIUS:
		return(true)
	else:
		return(false)

const Flash = preload("res://lib/flash/flash.tscn")
func play_flash(screen_position: Vector2) -> void:
	var _f = Flash.instantiate()
	_f.global_position = screen_position
	_f.z_index = 100
	hud.get_node("TopLevel").add_child(_f)

func dismiss_hints() -> void:
	for _h in hud.get_node("TopLevel").get_children():
		if _h is HintPanel:
			_h.close()

const Hint = preload("res://lib/hint/hint.tscn")
func play_hint(id: String, data: Dictionary, position: Vector2, play_once = false) -> HintPanel:
	dismiss_hints()
	
	if play_once:
		if id in Save.data.hints_played:
			#print("[Global] discarding already-played hint '" + id + "'")
			return # already played
		Save.data.hints_played.append(id)
	
	var _hint = Hint.instantiate()
	hud.get_node("TopLevel").add_child(_hint)
	_hint.position = position
	_hint.set_text(data)
	return(_hint)

const EXPN_PATH_PREFIX = "res://expansions/"

func load_expn(id: String) -> void:
	var expn_path = EXPN_PATH_PREFIX + id
	var _e = load(expn_path + "/expn_data.gd").data
	var expn_data = _e.duplicate(true)
	
	for _d in expn_data:
		var deco_path = expn_path + "/" + _d
		expn_data[_d].scene = deco_path + "/" + _d + ".tscn"
		var cursor_path
		if "cursor_suffix" in expn_data[_d]:
			cursor_path = deco_path + "/" + _d + "_mesh." + expn_data[_d].cursor_suffix
		else:
			cursor_path = deco_path + "/" + _d + "_mesh.glb"
		expn_data[_d].cursor_model = cursor_path
		DecoData[_d] = expn_data[_d]

func play_flux_sound() -> void:
	$DiscombobulatorUse.play()

##### Execution

func _init() -> void:
	var debug_cmd = false
	var args = Array(OS.get_cmdline_args())
	if args.has("--debug=true"):
		debug_cmd = true
	if OS.is_debug_build() or debug_cmd:
		debug_allowed = true
	else: debug_allowed = false

#func _input(_event: InputEvent) -> void:
	#if Input.is_action_just_pressed("print_all_nodes"):
		#if debug_allowed:
			#var _nc = 0
			#for _n in Utilities.get_all_children(get_tree().root):
				#print("  * " + str(_n) + " (" + str(_n.name) + ")")
				#_nc += 1
			#print("--- Finished with " + str(_nc) + " node(s) counted. ---")

func _ready() -> void:
	add_child(skill_cooldown_timer)
	skill_cooldown_timer.one_shot = true
	
	if !Engine.is_editor_hint():
		
		DiscordRPC.app_id = 1367709882530140191
		DiscordRPC.register_steam(3561310)
		DiscordRPC.state = "In Menu"
		DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
		if DiscordRPC.get_is_discord_working():
			DiscordRPC.refresh()
	
	Utilities.set_master_vol(0.0)
	
	var _d = preload("res://lib/decoration/deco_data.gd").new()
	add_child(_d)
	DecoData = _d.DecoData.duplicate(true)
	load_expn("kodan")
	load_expn("kryta")
	
	karma_collected.connect(func():
		var _p = 0.9 + rng.randf() * 0.2 # pitch variance
		$KarmaCollect.pitch_scale = _p
		$KarmaCollect.play())

	# Set up retina
	if DisplayServer.screen_get_size().x > 2000:
		# macOS already configures the cursor for retina
		if OS.get_name() != "macOS":
			get_window().content_scale_factor = 1.75
			retina_scale = 1.75
			DisplayServer.cursor_set_custom_image(
				load("res://generic/textures/cursor_2x.png"))
		else:
			get_window().content_scale_factor = 2.0
			retina_scale = 2
		if !Engine.is_embedded_in_editor():
			get_window().size *= retina_scale
	if !Engine.is_embedded_in_editor():
		get_window().min_size = Vector2i(
			floor(1280 * Global.retina_scale) - 1,
			floor(720 * Global.retina_scale) - 1)
		get_window().position = (
			DisplayServer.screen_get_position() + Vector2i(32, 64))
	
	await get_tree().process_frame
	get_window().size_changed.connect(func():
		await get_tree().process_frame
		if get_window().mode == Window.MODE_MAXIMIZED:
			SettingsHandler.update("window_mode", "maximized")
			SettingsHandler.save_to_file()
		elif get_window().mode == Window.MODE_WINDOWED:
			if (!SettingsHandler.settings.window_mode == "windowed"
				and !SettingsHandler.settings.window_mode == "windowed_(1080p)"):
				SettingsHandler.update("window_mode", "windowed")
				SettingsHandler.save_to_file())

func _process(_delta):
	Steam.run_callbacks() # process Steam

func _on_click_sound() -> void:
	$Click.play()

# Skill cooldowns
const SKILL_COOLDOWN_TIME = 0.2
var on_skill_cooldown = false
@onready var skill_cooldown_timer = Timer.new()

func do_skill_cooldown() -> void:
	if on_skill_cooldown: return
	on_skill_cooldown = true
	skill_cooldown_timer.wait_time = SKILL_COOLDOWN_TIME
	skill_cooldown_timer.start()
	
	await skill_cooldown_timer.timeout
	on_skill_cooldown = false
