extends "res://lib/map/map.gd"

@onready var toolbox = get_node("HUD/Toolbox")
var y_target = 0.0

#func spawn_spider() -> void:
	#var _s = load("res://lib/spider/spider.tscn").instantiate()
	#add_child(_s)
	#_s.global_position = Vector3(
		#Global.player_position.x,
		#y_target,
		#Global.player_position.z)
	#
	#Global.move_player.emit(Vector3(
		#Global.player_position.x,
		#y_target + 1.0,
		#Global.player_position.z))
	#
	#Global.walk_mode_target = _s

func set_marker_pos() -> void: # set the position of the story marker
	match Save.data.story_point:
		"game_start": $StoryMarker.position = $Pulley.position
		"pick_weeds": $StoryMarker.position = $WeedBin.position
		"clear_bugs": $StoryMarker.global_position = $Discombobulator/SpatialText.global_position - Vector3(0, 0.9, 0)
		"_": $StoryMarker.position = Vector3(0, -10, 0) # hide under map

func _ready() -> void:
	#Global.walk_mode_target = $Spider
	
	$Landscape/LandscapeCol.set_collision_layer_value(2, true)
	super()
	
	Save.story_advanced.connect(set_marker_pos)
	await get_tree().process_frame
	set_marker_pos()
	
	#Global.walk_mode_entered.connect(spawn_spider)
	#Global.walk_mode_left.connect(func():
		#Global.walk_mode_target.queue_free())
	#Global.command_sent.emit("/cleardeco")

#func _process(_delta: float) -> void:
	#y_target = $Player/YCast.get_collision_point().y
