extends Node3D
# DecoHandler
# Manages the placing and removal of decorations

const TEST_DECORATION = preload("res://decorations/lantern/deco_lantern.tscn")

func place_decoration(data: Dictionary) -> void:
	#var _d = TEST_DECORATION.instantiate()
	# For now, if no scene is specified for the decoration, nothing will happen
	if !Global.queued_decoration in Global.DecoData: return
	var _data = Global.DecoData[Global.queued_decoration]
	if !"scene" in _data: return
	
	var _d = load(_data.scene).instantiate()
	add_child(_d)
	_d.global_position = data.position
	if "y_rotation" in data:
		_d.global_rotation.y = data.y_rotation
	Global.decorations.append(_d)

func _load_decorations() -> void:
	# TODO: loading decorations
	pass

func _save_decorations() -> void:
	var _decoration_save_data = {}
	for _n in get_children():
		if _n is Decoration:
			_decoration_save_data[_n.id] = {
				"position": _n.global_position,
				"rotation": _n.global_rotation,
				"scale": _n.scale
			}
	var _file = FileAccess.open("user://deco.dat", FileAccess.WRITE)
	_file.store_var(_decoration_save_data)
	_file.close()

func _input(_event: InputEvent) -> void:
	if Global.tool_mode == Global.TOOL_MODE_PLACE:
		if Input.is_action_just_pressed("right_click"):
			Global.deco_placement_canceled.emit()

func _ready() -> void:
	for _n in get_children():
		if _n is Decoration:
			Global.decorations.append(_n)
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/savedeco":
			_save_decorations())
	
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
	
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/cleardeco":
			for _n in get_children():
				if _n is Decoration:
					_n.queue_free()
			Global.decorations = [])
