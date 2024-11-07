extends Node3D
# DecoHandler
# Manages the placing and removal of decorations

const TEST_DECORATION = preload("res://decorations/lantern/deco_lantern.tscn")

func place_decoration(data: Dictionary) -> void:
	var _d = TEST_DECORATION.instantiate()
	add_child(_d)
	_d.global_position = data.position
	if "y_rotation" in data:
		_d.global_rotation.y = data.y_rotation
	Global.decorations.append(_d)

func _ready() -> void:
	for _n in get_children():
		if _n is Decoration:
			Global.decorations.append(_n)
	
	Global.mouse_3d_click.connect(func():
		if Global.tool_mode == Global.TOOL_MODE_PLACE:
			place_decoration({
				"position": Global.mouse_3d_position,
				"y_rotation": Global.mouse_3d_y_rotation
			})
			Global.deco_placed.emit()
			Global.jade_bot_sound.emit()
			Global.queued_decoration = "none"
			Global.set_cursor(false))
