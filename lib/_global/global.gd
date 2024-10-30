extends Node

var camera: Camera3D # reference for ray projections
var crumb_handler: CrumbHandler

var foliage_count = 0
var in_exclusive_ui = false
var mouse_in_ui = false
var camera_orbiting = true
var player_position = Vector3.ZERO
var popup_open = false
var retina_scale = 1

signal click_sound
signal jade_bot_sound

##### Decoration signals and parameters

enum {TOOL_MODE_NONE, TOOL_MODE_ADJUST, TOOL_MODE_SELECT}
const tool_identities = [ # associations for debug printing
	"TOOL_MODE_NONE",
	"TOOL_MODE_ADJUST",
	"TOOL_MODE_SELECT" ]

signal adjustment_applied # transformation applied and adjustment ended
signal adjustment_canceled # transformation discarded and adjustment ended
signal adjustment_started

# Decoration currently being adjusted
var active_decoration: Decoration = null
var tool_mode = TOOL_MODE_NONE

##### Cursor signals and parameters

var cursor_active = false

signal cursor_enabled(data: Dictionary)
signal cursor_disabled
signal cursor_tint_changed(color: Color)

# Set the cursor on or off
func set_cursor(state = true) -> void:
	if state:
		if cursor_active: return # don't enable twice
		cursor_enabled.emit()
	else:
		if !cursor_active: return # don't disable twice
		cursor_disabled.emit()
	cursor_active = state

##### Execution

func _ready() -> void:
	Utilities.set_master_vol(0.0)
	
	# Set up retina
	if DisplayServer.screen_get_size().x > 2000:
		retina_scale = 2
		get_window().size *= retina_scale
		get_window().content_scale_factor = retina_scale
		# macOS already configures the cursor for retina
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(
				load("res://generic/textures/cursor_2x.png"))

func _on_click_sound() -> void:
	$Click.play()
