class_name DesignHandler extends Node
# DesignHandler
# Gets parented to DecorationHandler

const DPATH = "user://save/designs"

signal file_op_completed # file operation completed

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
		create_design_slot("default")
