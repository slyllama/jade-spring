extends Node

var mouse_in_ui = false
var camera: Camera3D # reference for ray projections

# Decoration signals and parameters
enum {TOOL_MODE_NONE, TOOL_MODE_ADJUST, TOOL_MODE_SELECT}
const tool_identities = [ # associations for debug printing
	"TOOL_MODE_NONE",
	"TOOL_MODE_ADJUST",
	"TOOL_MODE_SELECT" ]

signal adjustment_applied # transformation applied and adjustment ended
signal adjustment_canceled # transformation discarded and adjustment ended
signal adjustment_started

var active_decoration: Decoration = null # the decoration currently being adjusted
var tool_mode = TOOL_MODE_NONE
