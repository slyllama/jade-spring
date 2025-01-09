extends "res://lib/map/map.gd"

@onready var toolbox = get_node("HUD/Toolbox")
var y_target = 0.0

func set_marker_pos() -> void: # set the position of the story marker
	match Save.data.story_point:
		"game_start": $StoryMarker.position = $Pulley.position
		"pick_weeds": $StoryMarker.position = $WeedBin.position
		"clear_bugs": $StoryMarker.global_position = $Discombobulator/SpatialText.global_position - Vector3(0, 0.9, 0)
		"_": $StoryMarker.position = Vector3(0, -10, 0) # hide under map

func _ready() -> void:
	$Landscape/LandscapeCol.set_collision_layer_value(2, true)
	super()
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/cinematic=on":
			Input.action_press("toggle_debug")
			Global.command_sent.emit("/playersmooth=0.3")
			Global.command_sent.emit("/speedratio=0.65")
			Global.command_sent.emit("/orbitsmooth=0.16")
		elif _cmd == "/cinematic=off":
			Global.command_sent.emit("/playersmooth=1.0")
			Global.command_sent.emit("/speedratio=1.0")
			Global.command_sent.emit("/orbitsmooth=1.0")
		)
	
	Save.story_advanced.connect(set_marker_pos)
	await get_tree().process_frame
	set_marker_pos()

const OCEAN_Z_MIN = 4.5
const OCEAN_Z_MAX = 10.0

func _process(_delta: float) -> void:
	var _player_z = Global.player_position.z
	var _ocean_proximity = clamp((_player_z - OCEAN_Z_MIN) / (OCEAN_Z_MAX - OCEAN_Z_MIN), 0.0, 1.0)
	$Ambience/Ocean.volume_db = linear_to_db(_ocean_proximity * 0.85)
