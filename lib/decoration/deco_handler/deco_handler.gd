extends Node3D
# DecoHandler
# Manages the placing and removal of decorations

const TEST_DECORATION = preload("res://decorations/lantern/deco_lantern.tscn")
const FILE_PATH = "user://deco.dat"

var default_deco_data = {}

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
	
	Global.command_sent.emit("/savedeco")

# Clear all decorations from the world
func _clear_decorations() -> void:
	print("clearing decorations")
	for _n in get_children():
		if _n is Decoration:
			_n.queue_free()
	Global.decorations = []

# Load decorations into the world from a dataset
# TODO: it might be best to perform this asynchronously
func _load_decorations(data = []) -> void:
	_clear_decorations()
	for _d in data:
		if !_d.id in Global.DecoData: continue
		var _decoration = load(Global.DecoData[_d.id].scene).instantiate()
		
		add_child(_decoration)
		_decoration.position = _d.position
		_decoration.rotation = _d.rotation
		_decoration.scale = _d.scale
		Global.decorations.append(_decoration)

# Load decorations from a file as a dictionary to use with other functions
func _load_decoration_file() -> Array:
	if FileAccess.file_exists(FILE_PATH):
		var file = FileAccess.open(FILE_PATH, FileAccess.READ)
		var _file_decos = file.get_var()
		file.close()
		return(_file_decos)
	else:
		return([])

func _get_decoration_list() -> Array:
	var _decoration_save_data = []
	for _n in get_children():
		if _n is Decoration:
			_decoration_save_data.append({
				"id": _n.id,
				"position": _n.global_position,
				"rotation": _n.global_rotation,
				"scale": _n.scale
			})
	return(_decoration_save_data)

func _save_decorations() -> void:
	var _decoration_save_data = _get_decoration_list()
	var _file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	_file.store_var(_decoration_save_data)
	_file.close()

#func _input(_event: InputEvent) -> void:
	#if Global.tool_mode == Global.TOOL_MODE_PLACE:
		#if Input.is_action_just_pressed("right_click"):
			#Global.deco_placement_canceled.emit()

func _ready() -> void:
	for _n in get_children():
		if _n is Decoration:
			Global.decorations.append(_n)
	default_deco_data = _get_decoration_list()
	
	# Load saved decorations or reset them depending on parameters passed from the main menu
	if Global.start_params.new_save:
		_load_decorations(default_deco_data)
		_save_decorations()
	else:
		_load_decorations(_load_decoration_file())
	
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
			_clear_decorations()
			Global.announcement_sent.emit("((Decorations cleared))")
		elif _cmd == "/loaddeco":
			_load_decorations(_load_decoration_file())
			Global.announcement_sent.emit("((Decorations loaded))")
		elif _cmd == "/resetdeco":
			_load_decorations(default_deco_data)
			Global.announcement_sent.emit("((Decorations reset))")
		elif _cmd == "/savedeco":
			Global.announcement_sent.emit("((Decorations saved))")
			_save_decorations()
		elif _cmd == "/getdecolist":
			_get_decoration_list()
	)
