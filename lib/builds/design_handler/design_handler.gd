class_name DesignHandler extends Node
# DesignHandler
# Gets parented to DecorationHandler

const DPATH = "user://designs"

# Generate a design slot from the current decoration list.
func create_design_slot(design_name: String = SettingsHandler.settings.current_design) -> void:
	print("[DesignHandler] creating slot '" + design_name + "'...")
	DirAccess.copy_absolute(
		"user://save/deco.dat", DPATH + "/" + design_name + ".dat")

func load_slot(design_name: String = SettingsHandler.settings.current_design) -> void:
	SettingsHandler.update("current_design", design_name)
	DirAccess.copy_absolute(
		DPATH + "/" + design_name + ".dat", "user://save/deco.dat")
	
	await get_tree().process_frame
	Global.deco_handler._load_decorations(
		Global.deco_handler._load_decoration_file())

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
		create_design_slot("default")
