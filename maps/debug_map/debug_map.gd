extends "res://lib/map/map.gd"

@onready var toolbox = get_node("HUD/Toolbox")
var y_target = 0.0

func spawn_spider() -> void:
	var _s = load("res://lib/spider/spider.tscn").instantiate()
	add_child(_s)
	_s.global_position = Vector3(
		Global.player_position.x,
		y_target,
		Global.player_position.z)
	
	Global.move_player.emit(Vector3(
		Global.player_position.x,
		y_target + 1.0,
		Global.player_position.z))
	
	Global.walk_mode_target = _s

func _ready() -> void:
	#Global.walk_mode_target = $Spider
	super()
	Global.walk_mode_entered.connect(spawn_spider)
	Global.walk_mode_left.connect(func():
		Global.walk_mode_target.queue_free())
	#Global.command_sent.emit("/cleardeco")
	
	$LandscapeTest/LandscapeCol.set_collision_layer_value(2, true)

func _process(_delta: float) -> void:
	y_target = $Player/YCast.get_collision_point().y

func _on_add_weed_button_down() -> void:
	Global.add_qty_effect("weed")

func _on_clear_weeds_button_down() -> void:
	Global.remove_effect.emit("weed")
