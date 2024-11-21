extends Node

var camera: Camera3D # reference for ray projections
var crumb_handler: CrumbHandler

var can_move = true
var current_crumb = null
var crumb_data = { } # reports both total counts and progress
var debug_enabled = false
var deco_button_pressed = false # this will become true on mouse down - decoration placement will not happen until it has been cleared
var current_effects = [ ]
var foliage_count = 0
var in_exclusive_ui = false
var mouse_3d_position = Utilities.BIGVEC3
var mouse_3d_y_rotation = 0.0
var mouse_in_ui = false
var mouse_in_deco_pane = false
var camera_orbiting = true
var player_position = Vector3.ZERO
var player_y_rotation = 0.0
var popup_open = false
var retina_scale = 1

signal announcement_sent(get_text)
signal bug_crumb_entered
signal bug_crumb_left
signal click_sound
signal crumbs_updated
signal debug_toggled
signal fishing_started
signal fishing_canceled
signal generic_area_entered
signal generic_area_left
signal jade_bot_sound
signal mouse_3d_click

signal add_effect(id) # more of a function signal - a shortcut to FXList
signal remove_effect(id)

##### Decoration signals and parameters
const DecoData = {
	"lantern": {
		"name": "Lantern",
		"scene": "res://decorations/lantern/deco_lantern.tscn",
		"cursor_model": "res://decorations/lantern/lantern.glb",
		"preview_scale": 0.9
	},
	"fountain": {
		"name": "Waterfall Fountain",
		"scene": "res://decorations/fountain/deco_fountain.tscn",
		"cursor_model": "res://decorations/fountain/fountain.glb",
		"y_rotation": 90,
		"preview_scale": 0.34
	},
	"shing_jea_arch": {
		"name": "Shing Jea Arch",
		"scene": "res://decorations/shing_jea_arch/deco_shing_jea_arch.tscn",
		"cursor_model": "res://maps/seitung/meshes/arch_test.glb",
		"y_rotation": 115,
		"preview_scale": 0.42
	},
	"bloodstone_impacted_pillar": {
		"name": "Bloodstone-Impacted Pillar",
		"scene": "res://decorations/bloodstone_impacted_pillar/deco_bloodstone_impacted_pillar.tscn",
		"cursor_model": "res://decorations/bloodstone_impacted_pillar/bloodstone_impacted_pillar.glb",
		#"y_rotation": 115,
		"preview_scale": 0.73
	}
}

enum {
	TOOL_MODE_NONE,
	TOOL_MODE_ADJUST,
	TOOL_MODE_SELECT,
	TOOL_MODE_PLACE,
	TOOL_MODE_FISH }
enum {TRANSFORM_MODE_OBJECT, TRANSFORM_MODE_WORLD}

const tool_identities = [ # associations for debug printing
	"TOOL_MODE_NONE",
	"TOOL_MODE_ADJUST",
	"TOOL_MODE_SELECT",
	"TOOL_MODE_PLACE",
	"TOOL_MODE_FISH" ]

signal adjustment_applied # transformation applied and adjustment ended
signal adjustment_canceled # transformation discarded and adjustment ended
signal adjustment_started
signal adjustment_mode_rotation
signal adjustment_mode_translate

signal deco_pane_closed
signal deco_pane_opened
signal deco_placement_started
signal deco_placement_canceled
signal deco_placed(data)
signal transform_mode_changed(transform_mode)

var decorations = [] # references to decorations will populate here

var active_decoration: Decoration = null # decoration currently being adjusted
var queued_decoration = "none" # next decoration that will be placed
var tool_mode = TOOL_MODE_NONE
var transform_mode = TRANSFORM_MODE_OBJECT

func toggle_transform_mode() -> void:
	if transform_mode == TRANSFORM_MODE_WORLD:
		transform_mode = TRANSFORM_MODE_OBJECT
	else:
		transform_mode = TRANSFORM_MODE_WORLD
	transform_mode_changed.emit(transform_mode)

##### Cursor signals and parameters

var cursor_active = false

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

##### Execution

func _ready() -> void:
	Utilities.set_master_vol(0.0)
	
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
		get_window().size *= retina_scale

func _on_click_sound() -> void:
	$Click.play()
