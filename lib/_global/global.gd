extends Node

var mouse_in_ui = false
var camera: Camera3D # reference for ray projections
var foliage_count = 0
var player_position = Vector3.ZERO

# Decoration signals and parameters

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

# Execution

func _ready() -> void:
	# Set up retina
	if DisplayServer.screen_get_size().x > 2000:
		get_window().size *= 2
		get_window().content_scale_factor = 2
		# macOS already configures the cursor for retina
		if OS.get_name() != "macOS":
			DisplayServer.cursor_set_custom_image(
				load("res://generic/textures/cursor_2x.png"))
