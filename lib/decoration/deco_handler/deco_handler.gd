class_name DecoHandler extends Node3D
# DecoHandler
# Manages the placing and removal of decorations

const DecoThreadedLoader = preload("res://lib/decoration/deco_threaded_loader/deco_threaded_loader.tscn")
const FILE_PATH = "user://save/deco.dat"
var default_deco_data = {}

var eligible_for_homesteader = false
var eligible_for_architect = false

func get_deco_count() -> Dictionary:
	var _d = {}
	for _n in get_children():
		if _n is Decoration:
			if !_n.id in _d: _d[_n.id] = 1
			else: _d[_n.id] += 1
	return(_d)

# Duplicate the contents of Global.deco_selection_array
func duplicate_decoration_selection() -> void:
	var _new_deco_selection_array = []
	for _d in Global.deco_selection_array:
		_d.node.set_selected(false)
		var _d_new = _d.node.duplicate()
		add_child(_d_new)
		_d_new.set_selected()
		_d_new.position += Vector3(0.5, 0.5, 0.5)
		_new_deco_selection_array.append({
			"node": _d_new, "last_position": _d_new.position })
	Global.deco_selection_array = _new_deco_selection_array
	
func place_decoration(data: Dictionary) -> void:
	if !Global.queued_decoration in Global.DecoData: return
	var _data = Global.DecoData[Global.queued_decoration]
	if !"scene" in _data: return
	
	var _d = load(_data.scene).instantiate()
	add_child(_d)
	_d.global_position = data.position
	if "rotation" in data:
		if data.rotation:
			_d.rotation = data.rotation
	if "y_rotation" in data:
		_d.global_rotation.y = data.y_rotation
	if "x_rotation" in data:
		_d.global_rotation.x = data.x_rotation
	if "eyedrop_scale" in data:
		_d.scale = data.eyedrop_scale
	Global.command_sent.emit("/savedeco")
	
	Global.deco_count += 1
	Global.deco_count_changed.emit()
	
	await get_tree().process_frame
	
	SteamHandler.add_to_stat("decos_placed")
	if SteamHandler.get_stat("decos_placed") >= 25 and eligible_for_homesteader:
		# Manual call for passing "Homesteader" achievement
		eligible_for_homesteader = false
		SteamHandler.store_stats()
	if SteamHandler.get_stat("decos_placed") >= 50 and eligible_for_architect:
		# Manual call for passing "Architect" achievement
		eligible_for_architect = false
		SteamHandler.store_stats()
	
	Global.deco_count += 1
	_d.start_adjustment()

# Clear all decorations from the world
func _clear_decorations() -> void:
	for _n in get_children():
		if _n is Decoration:
			_n.queue_free()

var _deco_count_position := 0 # increment when a decoration load is finalized

signal load_increment

func _load_decorations(data = []) -> void:
	await get_tree().process_frame # race condition with HUD reveal
	_clear_decorations()
	
	_deco_count_position = 0
	Global.deco_load_started.emit()
	Global.deco_count = data.size()
	Global.deco_count_changed.emit()
	
	if data.size() == 0:
		_save_decorations()
		Global.decorations_loaded.emit()
		Global.deco_load_ended.emit()
		return
	
	var batched_data := {}
	for _d in data:
		if !_d.id in Global.DecoData: continue
		var _deco_spawn_data = SpawnData.new()
		_deco_spawn_data.position = _d.position
		_deco_spawn_data.rotation = _d.rotation
		_deco_spawn_data.scale = _d.scale
		if _d.id in batched_data:
			batched_data[_d.id].append(_deco_spawn_data)
		else: batched_data[_d.id] = [_deco_spawn_data]
	
	for _b in batched_data:
		var _deco_loader: DecoThreadedLoaderScript = DecoThreadedLoader.instantiate()
		_deco_loader.deco_id = _b
		_deco_loader.spawn_data = batched_data[_b]
		_deco_loader.loaded.connect(func():
			load_increment.emit()
			_deco_count_position += batched_data[_b].size()
			if _deco_count_position == Global.deco_count: # finished
				await get_tree().process_frame
				_save_decorations()
				Global.decorations_loaded.emit()
				Global.deco_load_ended.emit())
		add_child.call_deferred(_deco_loader)
		await load_increment

# Load decorations from a file as a dictionary to use with other functions
func _load_decoration_file(deco_path = FILE_PATH) -> Array:
	if !".dat" in deco_path: return([]) # not a DAT file
	if FileAccess.file_exists(deco_path):
		var file = FileAccess.open(deco_path, FileAccess.READ)
		var _file_decos = file.get_var()
		file.close()
		if _file_decos is Array:
			return(_file_decos)
		else: return([])
	else: return([])

func _get_decoration_list() -> Array:
	var _decoration_save_data = []
	for _n in get_children():
		if _n is Decoration:
			_decoration_save_data.append({
				"id": _n.id,
				"position": _n.global_position,
				"rotation": _n.rotation,
				"scale": _n.scale
			})
	return(_decoration_save_data)

func _save_decorations() -> void:
	if Global.map_name != "seitung": return # not saving
	
	var _decoration_save_data = _get_decoration_list()
	var _file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	_file.store_var(_decoration_save_data)
	_file.close()

func _ready() -> void:
	Global.deco_handler = self
	default_deco_data = _get_decoration_list()
	
	# Strict eligibility for achievements
	if SteamHandler.get_achievment_completion("homesteader") == 0:
		eligible_for_homesteader = true
	if SteamHandler.get_achievment_completion("architect") == 0:
		eligible_for_architect = true
	
	Global.deco_deleted.connect($DeleteSound.play)
	if Global.start_params.new_save:
		_save_decorations() # commit reset decorations
	
	Global.adjustment_applied.connect(func():
		if Global.current_gadget:
			Global.current_gadget._on_body_entered(Global.player))
	
	Global.mouse_3d_click.connect(func():
		if Global.cursor_in_safe_point(): return
		if Global.tool_mode == Global.TOOL_MODE_PLACE:
			place_decoration({
				"position": Global.mouse_3d_position,
				"y_rotation": Global.mouse_3d_y_rotation,
				"x_rotation": Global.mouse_3d_x_rotation,
				"eyedrop_scale": Global.mouse_3d_scale,
				"rotation": Global.mouse_3d_override_rotation
			})
			Global.deco_placed.emit()
			Global.jade_bot_sound.emit()
			Global.queued_decoration = "none"
			Global.set_cursor(false))
	
	# Commands (useful for debugging)
	Global.command_sent.connect(func(_cmd):
		if _cmd == "/cleardeco":
			_clear_decorations()
			await get_tree().process_frame
			_save_decorations()
		elif _cmd == "/loaddeco":
			_load_decorations(_load_decoration_file())
			await Global.deco_load_ended
			Global.announcement_sent.emit("((Loaded decorations from file))")
		elif _cmd == "/resetdeco":
			var _default_data = _load_decoration_file(
			"res://maps/seitung/default_deco.dat")
			_load_decorations(_default_data)
			await Global.deco_load_ended
			_save_decorations()
		elif _cmd == "/savedeco":
			_save_decorations()
		elif _cmd == "/getdecolist":
			_get_decoration_list()
		elif _cmd == "/getdecocount":
			print(get_deco_count()))

func _on_design_handler_ready() -> void:
	# Load saved decorations or reset them depending on parameters passed from the main menu
	# This doesn't happen until the DesignHandler is ready
	if Global.map_name == "debug": return
	
	if !Global.start_params.new_save:
		print("[DecoHandler] Loading design '"
			+ SettingsHandler.settings.current_design + "'.")
		_load_decorations(_load_decoration_file())
	else:
		print("Loading default decoration file.")
		var _default_data = _load_decoration_file("res://maps/seitung/default_deco.dat")
		_load_decorations(_default_data)
