class_name DesignHandler extends Node
# DesignHandler
# Gets parented to DecorationHandler

const DPATH = "user://save/designs"
const VALID_CHARS = [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
	"l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
	"P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4",
	"5", "6", "7", "8", "9", "0", "-", "_", " " ]

signal file_op_completed # file operation completed

func return_valid_name(input_name: String) -> String:
	var _invalid_chars = 0
	var _s = input_name
	for _c in _s:
		if !_c in VALID_CHARS:
			_invalid_chars += 1
			_s = _s.replace(_c, "")
	
	if _invalid_chars == input_name.length(): # if every char is invalid
		return(return_valid_name("build"))
	
	var _input_name_no_number = ""
	var _needs_incrementing = false
	var _numbers_complete = false
	for _c in _s.reverse():
		if !_c.is_valid_int(): # if it is a letter
			_input_name_no_number = _c + _input_name_no_number
			if !_numbers_complete:
				_numbers_complete = true
		else:
			if _numbers_complete:
				_input_name_no_number = _c + _input_name_no_number
	var _lowest_number = 999
	var _highest_number = 0
	for _d in get_slots():
		var _n = _d.replace(".dat", "").replace(_input_name_no_number, "")
		if _d.replace(".dat", "") == _s:
			_lowest_number = 0
			_needs_incrementing = true
		if _n.is_valid_int():
			_needs_incrementing = true
			_n = int(_n)
			if _n < _lowest_number: _lowest_number = _n
			if _n > _highest_number: _highest_number = _n
	
	if _needs_incrementing:
		if _lowest_number == 1:
			return(_input_name_no_number)
		if _lowest_number > 1:
			return(_input_name_no_number + str(_lowest_number - 1))
		return(_input_name_no_number + str(_highest_number + 1))
	return(_s)

# Generate a design slot from the current decoration list.
func create_design_slot(design_name: String = SettingsHandler.settings.current_design) -> void:
	if Global.map_name == "debug":
		print("[DesignHandler] Tried to create or update a design, but we are in debug mode.")
		return
	print("[DesignHandler] creating slot '" + design_name + "'...")
	DirAccess.copy_absolute(
		"user://save/deco.dat", DPATH + "/" + design_name + ".dat")

# Create a design 
func create_custom_file(custom_design_path: String) -> void:
	var design_name = "eeby"
	print("[DesignHandler] creating slot '" + design_name + "'...")
	DirAccess.copy_absolute(
		custom_design_path, DPATH + "/" + design_name + ".dat")

func load_slot(design_name: String = SettingsHandler.settings.current_design) -> void:
	SettingsHandler.update("current_design", design_name)
	SettingsHandler.save_to_file()
	DirAccess.copy_absolute(
		DPATH + "/" + design_name + ".dat", "user://save/deco.dat")
	
	await get_tree().process_frame
	Global.deco_handler._load_decorations(
		Global.deco_handler._load_decoration_file())
	
	file_op_completed.emit()

func delete_slot(design_name: String) -> void:
	DirAccess.remove_absolute(DPATH + "/" + design_name + ".dat")

func rename_slot(from: String, to: String) -> void:
	var _from_path = DPATH + "/" + from + ".dat"
	var _to_path = DPATH + "/" + to + ".dat"
	print(_from_path)
	DirAccess.copy_absolute(_from_path, _to_path)
	await get_tree().process_frame
	DirAccess.remove_absolute(_from_path)
	
	file_op_completed.emit()

# Return a list of designs that the user has
func get_slots() -> PackedStringArray:
	var _d = DirAccess.open(DPATH)
	return(_d.get_files())

func _ready() -> void:
	Global.design_handler = self
	
	if !DirAccess.dir_exists_absolute(DPATH):
		# First time setup
		print("[DesignHandler] no path exists, creating...")
		DirAccess.make_dir_absolute(DPATH)
		
		SettingsHandler.update("current_design", "default")
		await get_tree().process_frame
		await Global.deco_handler.ready
		create_design_slot("default")
	
	if Global.start_params.new_save:
		SettingsHandler.update("current_design", "default")
		await get_tree().process_frame
		create_design_slot("default")
